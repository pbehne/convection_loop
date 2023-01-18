#####################################################################
# material properties assuming solid = UO2, fluid = He @ STP
#####################################################################
mu = '${units 1.96e-3 Pa*s}' # Exponent should be -5, but run into convergence issues (turbulence)
rho_fluid = '${units 1.78e-4 g/cm^3 -> kg/m^3}'
rho_fuel = '${units 10.97 g/cm^3 -> kg/m^3}'
k_fluid = '${units 0.02 W/(m*K)}'
k_fuel = '${units 10.2 W/(m*K)}'
cp_fluid = '${units 5.193 J/(kg*K)}'
cp_fuel = '${units 300 J/(kg*K)}'
T_cold = '${units 293 K}'
h_interface = '${units 20 W/(m^2*K)}' # convection coefficient at solid/fluid interface, tbd
alpha = '${units ${fparse 1/T_cold} K^(-1)}' # natural convection coefficient = 1/T assuming ideal gas
q_vol = '${units 10 kW/m^3 -> W/m^3}'

# numerical settings
velocity_interp_method = 'rc'
advected_interp_method = 'average'

[GlobalParams]
  rhie_chow_user_object = 'rc'
  two_term_boundary_expansion = false
[]

[UserObjects]
  [rc]
    type = INSFVRhieChowInterpolator
    u = vel_x
    v = vel_y
    pressure = pressure
    block = 1
  []
[]

[Mesh]
  [cmg]
    # Leftmost portion of mesh is block 0, rest is block 1
    # Block 0 is be solid heat source (spent fuel), block 1 is gasseous coolant
    type = CartesianMeshGenerator
    dim = 2
    dx = '1 0.5'
    dy = '0.5 4 0.5'
    ix = '50 25'
    iy = '25 200 25'
    subdomain_id = '1 1
                    0 1
                    1 1
                    '
  []
  [interface]
    # Define interface between solid and fluid surfaces as where blocks 0 and 1 meet
    type = SideSetsBetweenSubdomainsGenerator
    input = 'cmg'
    primary_block = 0
    paired_block = 1
    new_boundary = 'interface'
  []

  [left_fluid_boundaries]
    # Define portions of left boundary that are in fluid domain
    type = SideSetsFromBoundingBoxGenerator
    input = 'interface'
    block_id = 1
    bottom_left = '-0.1 0.5 0'
    top_right = '0.05 4.5 0'
    location = OUTSIDE
    boundaries_old = 'left'
    boundary_new = 10
  []

  coord_type = RZ
  rz_coord_axis = Y
[]

[Variables]
  [vel_x]
    # x component of velocity
    type = INSFVVelocityVariable
    block = 1
  []

  [vel_y]
    # y component of velocity
    type = INSFVVelocityVariable
    block = 1
  []

  [pressure]
    type = INSFVPressureVariable
    block = 1
  []

  [T]
    # Temperature field spans solid (block 0) and fluid (block 1)
    type = INSFVEnergyVariable
    #scaling = 1e-2
  []

  [lambda]
    # Not sure what this does, something to do with pressure normalization?
    family = SCALAR
    order = FIRST
  []
[]

###################################################
# Set up conservation equations to solve
###################################################

[FVKernels]
  # No mass time derivative because imcompressible (derivative = 0)
  [mass]
    type = INSFVMassAdvection
    variable = pressure
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    rho = ${rho_fluid}
    block = 1 # Mass is only advected in fluid domain
  []

  [mean_zero_pressure]
    type = FVIntegralValueConstraint
    variable = pressure
    lambda = lambda
    block = 1
  []

  [u_time]
    type = INSFVMomentumTimeDerivative
    rho = ${rho_fluid}
    momentum_component = 'x'
    variable = vel_x
    block = 1 # fluid domain
  []

  [u_advection]
    type = INSFVMomentumAdvection
    variable = vel_x
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    rho = ${rho_fluid}
    momentum_component = 'x'
    block = 1 # fluid domain
  []

  [u_viscosity]
    type = INSFVMomentumDiffusion
    variable = vel_x
    mu = ${mu}
    momentum_component = 'x'
    block = 1 # fluid domain
  []

  [u_pressure]
    type = INSFVMomentumPressure
    variable = vel_x
    momentum_component = 'x'
    pressure = pressure
    block = 1 # fluid domain
  []

  [u_buoyancy]
    # Natural convection term
    type = INSFVMomentumBoussinesq
    variable = vel_x
    T_fluid = T
    gravity = '0 -1 0'
    rho = ${rho_fluid}
    ref_temperature = ${T_cold}
    momentum_component = 'x'
    block = 1 # fluid domain
  []

  [u_gravity]
    # Natural convection term
    type = INSFVMomentumGravity
    variable = vel_x
    gravity = '0 -1 0'
    rho = ${rho_fluid}
    momentum_component = 'x'
    block = 1 # fluid domain
  []

  [v_time]
    type = INSFVMomentumTimeDerivative
    rho = ${rho_fluid}
    momentum_component = 'y'
    variable = vel_y
    block = 1 # fluid domain
  []

  [v_advection]
    type = INSFVMomentumAdvection
    variable = vel_y
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    rho = ${rho_fluid}
    momentum_component = 'y'
    block = 1 # fluid domain
  []

  [v_viscosity]
    type = INSFVMomentumDiffusion
    variable = vel_y
    mu = ${mu}
    momentum_component = 'y'
    block = 1 # fluid domain
  []

  [v_pressure]
    type = INSFVMomentumPressure
    variable = vel_y
    momentum_component = 'y'
    pressure = pressure
    block = 1 # fluid domain
  []

  [v_buoyancy]
    # natural convection term
    type = INSFVMomentumBoussinesq
    variable = vel_y
    T_fluid = T
    gravity = '0 -1 0'
    rho = ${rho_fluid}
    ref_temperature = ${T_cold}
    momentum_component = 'y'
    block = 1 # fluid domain
  []

  [v_gravity]
    # natural convection term
    type = INSFVMomentumGravity
    variable = vel_y
    gravity = '0 -1 0'
    rho = ${rho_fluid}
    momentum_component = 'y'
    block = 1 # fluid domain
  []

  [temp_time]
    type = INSFVEnergyTimeDerivative
    rho = ${rho_fluid}
    cp = ${cp_fluid}
    variable = T
    block = 1 # fluid domain in case different rho/cp
  []

  [temp_conduction]
    type = FVDiffusion
    coeff = 'k_fluid'
    variable = T
    block = 1 # fluid domain in case different k
  []

  [temp_advection]
    type = INSFVEnergyAdvection
    variable = T
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    block = 1 # advection in fluid domain only
  []

  [solid_temp_time]
    type = INSFVEnergyTimeDerivative
    rho = ${rho_fuel}
    cp = ${cp_fuel}
    variable = T
    block = 0 # solid domain in case different rho/cp
  []

  [solid_temp_conduction]
    type = FVDiffusion
    coeff = 'k_fuel'
    variable = T
    block = 0 # solid domain in case different k
  []

  [heat_source]
    # Spent fuel volumetric heat source in solid domain
    type = FVBodyForce
    variable = T
    function = vol_heat_rate
    block = 0
  []
[]

[FVInterfaceKernels]
  [convection]
    # define convection at the solid/fluid interface
    type = FVConvectionCorrelationInterface
    variable1 = T
    variable2 = T
    boundary = 'interface'
    h = ${h_interface}
    T_solid = T
    T_fluid = T
    subdomain1 = 1
    subdomain2 = 0
    wall_cell_is_bulk = true
    # Noticed unphysical solutions when using this instead of wall_cell_is_bulk
    #bulk_distance = 0.1
  []
[]

[FVBCs]
  # Note that left boundary of fluid domain is 'interface'
  [no_slip_x]
    type = INSFVNoSlipWallBC
    variable = vel_x
    boundary = 'interface right top bottom'
    function = 0
  []

  [no_slip_y]
    type = INSFVNoSlipWallBC
    variable = vel_y
    boundary = 'interface right top bottom'
    function = 0
  []

  [reflective_x]
    type = INSFVSymmetryVelocityBC
    variable = vel_x
    boundary = 10
    momentum_component = 'x'
    mu = ${mu}
    u = vel_x
    v = vel_y
  []

  [reflective_y]
    type = INSFVSymmetryVelocityBC
    variable = vel_y
    boundary = 10
    momentum_component = 'y'
    mu = ${mu}
    u = vel_x
    v = vel_y
  []

  [reflective_p]
    type = INSFVSymmetryPressureBC
    boundary = 10
    variable = pressure
  []

  [T_reflective]
    # symmetric problem
    type = FVNeumannBC
    variable = T
    boundary = 'left'
    value = 0
  []

  [T_cold_boundary]
    type = FVDirichletBC
    variable = T
    boundary = 'right top bottom'
    value = ${T_cold}
  []
[]

[ICs]
  [temp_ic]
    type = ConstantIC
    variable = T
    value = ${T_cold}
  []

  [vel_x]
    type = ConstantIC
    variable = vel_x
    value = 0
  []

  [vel_y]
    type = ConstantIC
    variable = vel_y
    value = 0
  []
[]

[Materials]
  # Associate material property values with required names
  [functor_constants_fuel]
    type = ADGenericFunctorMaterial
    prop_names = 'k_fuel'
    prop_values = '${k_fuel}'
    block = '0'
  []

  [functor_constants_fluid]
    type = ADGenericFunctorMaterial
    prop_names = 'alpha_b cp k_fluid'
    prop_values = '${alpha} ${cp_fluid} ${k_fluid}'
    block = '1'
  []

  [density_fluid]
    # needed for advection kernel
    type = INSFVEnthalpyMaterial
    temperature = 'T'
    rho = ${rho_fluid}
    block = 1
  []
[]

[Functions]
  [vol_heat_rate]
    # Function for volumetric heat rate that decaays to fraction f of its initial value by time T
    type = ParsedFunction
    expression = 'Q * exp((log(f) / T) * t) * sin(pi * y / 5)'
    symbol_names = 'Q f T'
    symbol_values = '${q_vol} 0.1 ${units 365 day -> s}'
  []
[]

[Executioner]
  type = Transient
  scheme = implicit-euler
  end_time = '${units 365 day -> s}'
  dtmax = '${units 10 day -> s}'
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = '${units 1 day -> s}'
  []
  #steady_state_detection = true
  #steady_state_tolerance = 1e-12

  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_factor_shift_type -snes_linesearch_damping'
  petsc_options_value = 'lu NONZERO 1.0'
  line_search = none
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-10
  automatic_scaling = true
[]

[Outputs]
  exodus = true
[]

#[Debug]
#  show_var_residual_norms = true
#[]
