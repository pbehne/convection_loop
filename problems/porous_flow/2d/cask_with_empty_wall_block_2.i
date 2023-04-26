#####################################################################
# material properties assuming solid = UO2, fluid = He @ STP
#####################################################################
mu = '${units 1.96e-3 Pa*s}' # Exponent should be -5, but run into convergence issues (turbulence)
rho_fluid = '${units 1.78e-4 g/cm^3 -> kg/m^3}'
k_fluid = '${units 0.02 W/(m*K)}'
k_steel = '${units 45 W/(m*k)}'
cp_fluid = '${units 5.193 J/(kg*K)}'
T_cold = '${units 293 K}'
alpha = '${units ${fparse 1/T_cold} K^(-1)}' # natural convection coefficient = 1/T assuming ideal gas
#Q = '${units 0.05 kW -> W}' # Heat source amplitude
Q = '${units 1.05 kW -> W}' # Heat source amplitude

# numerical settings
velocity_interp_method = 'rc'
advected_interp_method = 'average'

[Problem]
  kernel_coverage_check = false
[]

[GlobalParams]
  rhie_chow_user_object = 'rc'
  two_term_boundary_expansion = false
[]

[Mesh]
  [cmg]
    type = CartesianMeshGenerator
    dim = 2
    dx = '0.3683 0.0127'
    dy = '0.0127 0.2292 2.5146 0.2292 0.0127'
    #ix = '29 1'
    ix = '2 1'
    #iy = '1 18 200 18 1'
    iy = '1 2 3 2 1'
    subdomain_id = '0 0
                    1 0
                    2 0
                    1 0
                    0 0
                    '
  []

  [rename_block_name]
    type = RenameBlockGenerator
    input = cmg
    old_block = '0 1 2'
    new_block = 'wall_block spacer_block porous_block'
  []

  [solid_fluid_interface_1]
    type = SideSetsBetweenSubdomainsGenerator
    input = rename_block_name
    primary_block = porous_block
    paired_block = wall_block
    new_boundary = 'solid_fluid_interface'
  []

  [solid_fluid_interface_2]
    type = SideSetsBetweenSubdomainsGenerator
    input = solid_fluid_interface_1
    primary_block = spacer_block
    paired_block = wall_block
    new_boundary = 'solid_fluid_interface'
  []

  #[rename_interface]
  #  type = RenameBoundaryGenerator
  #  input = solid_fluid_interface_2
  #  old_boundary = 'solid_fluid_interface_1 solid_fluid_interface_2'
  #  new_boundary = 'solid_fluid_interface solid_fluid_interface'
  #[]

  [wall_left_boundary_1]
    type = SideSetsFromBoundingBoxGenerator
    #input = rename_interface
    input = solid_fluid_interface_2
    block_id = 0
    bottom_left = '0 0 0'
    top_right = '0.1 0.0127 0'
    boundaries_old = left
    boundary_new = wall_left
  []

  [wall_left_boundary_2]
    type = SideSetsFromBoundingBoxGenerator
    input = wall_left_boundary_1
    block_id = 0
    bottom_left = '0 2.9857 0'
    top_right = '0.1 2.9984 0'
    boundaries_old = left
    boundary_new = wall_left
  []

  [fluid_left_boundary]
    type = SideSetsFromBoundingBoxGenerator
    input = wall_left_boundary_2
    block_id = '2'
    bottom_left = '0 0.0127 0'
    top_right = '0.1 2.9857 0'
    boundaries_old = left
    boundary_new = fluid_left
  []

  #coord_type = RZ
  #rz_coord_axis = Y
[]

[UserObjects]
  [rc]
    type = PINSFVRhieChowInterpolator
    u = superficial_vel_x
    v = superficial_vel_y
    pressure = pressure
    porosity = porosity
    block = 'spacer_block porous_block'
  []
[]

[Variables]
  [superficial_vel_x]
    # x component of velocity
    type = PINSFVSuperficialVelocityVariable
    block = 'spacer_block porous_block'
  []

  [superficial_vel_y]
    # y component of velocity
    type = PINSFVSuperficialVelocityVariable
    block = 'spacer_block porous_block'
  []

  [pressure]
    type = INSFVPressureVariable
    block = 'spacer_block porous_block'
  []

  [T_fluid]
    type = INSFVEnergyVariable
    block = 'spacer_block porous_block'
  []

  [lambda]
    family = SCALAR
    order = FIRST
    block = 'spacer_block porous_block'
  []
[]

[AuxVariables]
  [porosity]
    type = MooseVariableFVReal
    block = 'spacer_block porous_block'
  []
[]

###################################################
# Set up conservation equations to solve
###################################################

[FVKernels]
  # No mass time derivative because imcompressible (derivative = 0)
  [mass]
    type = PINSFVMassAdvection
    variable = pressure
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    rho = ${rho_fluid}
    block = 'spacer_block porous_block'
  []

  [mean_zero_pressure]
    type = FVIntegralValueConstraint
    variable = pressure
    lambda = lambda
    block = 'spacer_block porous_block'
  []

  [u_time]
    type = PINSFVMomentumTimeDerivative
    rho = ${rho_fluid}
    momentum_component = 'x'
    variable = superficial_vel_x
    block = 'spacer_block porous_block'
  []

  [u_advection]
    type = PINSFVMomentumAdvection
    variable = superficial_vel_x
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    rho = ${rho_fluid}
    momentum_component = 'x'
    block = 'spacer_block porous_block'
    porosity = porosity
  []

  [u_viscosity]
    type = PINSFVMomentumDiffusion
    variable = superficial_vel_x
    mu = ${mu}
    momentum_component = 'x'
    block = 'spacer_block porous_block'
    porosity = porosity
  []

  [u_pressure]
    type = PINSFVMomentumPressure
    variable = superficial_vel_x
    momentum_component = 'x'
    pressure = pressure
    block = 'spacer_block porous_block'
    porosity = porosity
  []

  [u_buoyancy]
    # Natural convection term
    type = PINSFVMomentumBoussinesq
    variable = superficial_vel_x
    T_fluid = T_fluid
    gravity = '0 -1 0'
    rho = ${rho_fluid}
    ref_temperature = ${T_cold}
    momentum_component = 'x'
    block = 'spacer_block porous_block'
    porosity = porosity
  []

  [u_gravity]
    # Natural convection term
    type = PINSFVMomentumGravity
    variable = superficial_vel_x
    gravity = '0 -1 0'
    rho = ${rho_fluid}
    momentum_component = 'x'
    block = 'spacer_block porous_block'
    porosity = porosity
  []

  [v_time]
    type = PINSFVMomentumTimeDerivative
    rho = ${rho_fluid}
    momentum_component = 'y'
    variable = superficial_vel_y
    block = 'spacer_block porous_block'
  []

  [v_advection]
    type = PINSFVMomentumAdvection
    variable = superficial_vel_y
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    rho = ${rho_fluid}
    momentum_component = 'y'
    block = 'spacer_block porous_block'
    porosity = porosity
  []

  [v_viscosity]
    type = PINSFVMomentumDiffusion
    variable = superficial_vel_y
    mu = ${mu}
    momentum_component = 'y'
    block = 'spacer_block porous_block'
    porosity = porosity
  []

  [v_pressure]
    type = PINSFVMomentumPressure
    variable = superficial_vel_y
    momentum_component = 'y'
    pressure = pressure
    block = 'spacer_block porous_block'
    porosity = porosity
  []

  [v_buoyancy]
    # natural convection term
    type = PINSFVMomentumBoussinesq
    variable = superficial_vel_y
    T_fluid = T_fluid
    gravity = '0 -1 0'
    rho = ${rho_fluid}
    ref_temperature = ${T_cold}
    momentum_component = 'y'
    block = 'spacer_block porous_block'
    porosity = porosity
  []

  [v_gravity]
    # natural convection term
    type = PINSFVMomentumGravity
    variable = superficial_vel_y
    gravity = '0 -1 0'
    rho = ${rho_fluid}
    momentum_component = 'y'
    block = 'spacer_block porous_block'
    porosity = porosity
  []

  [temp_time]
    type = PINSFVEnergyTimeDerivative
    rho = ${rho_fluid}
    cp = ${cp_fluid}
    variable = T_fluid
    block = 'spacer_block porous_block'
    porosity = porosity
    is_solid = false
  []

  [temp_conduction]
    type = PINSFVEnergyDiffusion
    k = 'k_fluid'
    variable = T_fluid
    block = 'spacer_block porous_block'
    porosity = porosity
  []

  [temp_advection]
    type = PINSFVEnergyAdvection
    variable = T_fluid
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    block = 'spacer_block porous_block'
  []

  [heat_source]
    # Spent fuel volumetric heat source in solid domain
    type = FVBodyForce
    variable = T_fluid
    function = vol_heat_rate
    block = 'porous_block'
  []
[]

[FVBCs]
  [no_slip_x]
    type = INSFVNoSlipWallBC
    variable = superficial_vel_x
    boundary = 'solid_fluid_interface'
    function = 0
  []

  [no_slip_y]
    type = INSFVNoSlipWallBC
    variable = superficial_vel_y
    boundary = 'solid_fluid_interface'
    function = 0
  []

  [reflective_x]
    type = INSFVSymmetryVelocityBC
    variable = superficial_vel_x
    boundary = fluid_left
    momentum_component = 'x'
    mu = ${mu}
    u = superficial_vel_x
    v = superficial_vel_y
  []

  [reflective_y]
    type = INSFVSymmetryVelocityBC
    variable = superficial_vel_y
    boundary = fluid_left
    momentum_component = 'y'
    mu = ${mu}
    u = superficial_vel_x
    v = superficial_vel_y
  []

  [reflective_p]
    type = INSFVSymmetryPressureBC
    boundary = fluid_left
    variable = pressure
  []

  [T_reflective]
    # symmetric problem
    type = FVNeumannBC
    variable = T_fluid
    boundary = fluid_left
    value = 0
  []

  [T_cold_boundary]
    type = FVDirichletBC
    variable = T_fluid
    boundary = solid_fluid_interface
    value = ${T_cold}
  []
[]

[ICs]
  [porosity_spacer]
    type = ConstantIC
    variable = porosity
    block = spacer_block
    value = 1.0
  []

  [porosity_fuel]
    type = ConstantIC
    variable = porosity
    block = porous_block
    value = 0.1
  []

  [temp_ic_fluid]
    type = ConstantIC
    variable = T_fluid
    value = ${T_cold}
    block = 'spacer_block porous_block'
  []

  [superficial_vel_x]
    type = ConstantIC
    variable = superficial_vel_x
    value = 1E-5
    block = 'spacer_block porous_block'
  []

  [superficial_vel_y]
    type = ConstantIC
    variable = superficial_vel_y
    value = 1E-5
    block = 'spacer_block porous_block'
  []
[]

[Materials]
  [functor_constants_steel]
    type = ADGenericFunctorMaterial
    prop_names = 'k_steel'
    prop_values = '${k_steel}'
    block = wall_block
  []

  [functor_constants_fluid]
    type = ADGenericFunctorMaterial
    prop_names = 'alpha_b cp k_fluid'
    prop_values = '${alpha} ${cp_fluid} ${k_fluid}'
    block = 'spacer_block porous_block'
  []

  [density_fluid]
    # needed for advection kernel
    type = INSFVEnthalpyMaterial
    temperature = 'T_fluid'
    rho = ${rho_fluid}
    block = 'spacer_block porous_block'
  []
[]

[Functions]
  [vol_heat_rate]
    # Function for volumetric heat rate that decaays to fraction f of its initial value by time T
    type = ParsedFunction
    #expression = 'if(abs(y - 1.4993) < 0.01, if(abs(x - 0.1842) < 0.01, Q, 0), 0)'
    expression = 'Q'
    symbol_names = 'Q'
    symbol_values = '${Q}'
  []
[]

[Postprocessors]
  [dirichlet_heat_flux]
    type = SideDiffusiveFluxIntegral
    variable = T_fluid
    boundary = 'solid_fluid_interface'
    functor_diffusivity = ${k_fluid}
  []
  [neumann_heat_flux]
    type = SideDiffusiveFluxIntegral
    variable = T_fluid
    boundary = fluid_left
    functor_diffusivity = ${k_fluid}
  []
[]

[Executioner]
  type = Transient
  scheme = implicit-euler
  #end_time = '${units 1 s}'
  end_time = '${units 0.1 s}'
  dt = ${units 0.1 s}
  dtmin = ${units 0.1 s}

  solve_type = 'NEWTON'
  #solve_type = 'LINEAR'
  petsc_options_iname = '-pc_type -pc_factor_shift_type -snes_linesearch_damping'
  petsc_options_value = 'lu NONZERO 1.0'
  #petsc_options = '-ksp_view_pmat'
  line_search = none
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-10
  #nl_max_its = 2
  automatic_scaling = false
[]

[Outputs]
  exodus = true
[]

[Debug]
  show_var_residual_norms = true
[]
