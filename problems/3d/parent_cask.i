#####################################################################
# material properties assuming fluid = He @ STP
#####################################################################
mu = '${units 1.96e-3 Pa*s}' # Exponent should be -5, but run into convergence issues (turbulence)
rho_fluid = '${units 1.78e-4 g/cm^3 -> kg/m^3}'
k_fluid = '${units 0.02 W/(m*K)}'
cp_fluid = '${units 5.193 J/(kg*K)}'
T_cold = '${units 293 K}'
h_interface = '${units 20 W/(m^2*K)}' # convection coefficient at solid/fluid interface
alpha = '${units ${fparse 1/T_cold} K^(-1)}' # natural convection coefficient = 1/T assuming ideal gas

# mesh settings
pitch = '${units 0.032 m}'
mesh_path = "mesh/mesh14"

# numerical settings
velocity_interp_method = 'rc'
advected_interp_method = 'average'

[GlobalParams]
  rhie_chow_user_object = 'rc'
[]

[Problem]
  kernel_coverage_check = false
[]

[UserObjects]
  [rc]
    type = INSFVRhieChowInterpolator
    u = vel_x
    v = vel_y
    w = vel_z
    pressure = pressure
    block = 0
  []
[]

[Mesh]
  [fluid_rod]
    type = FileMeshGenerator
    file = 'mesh/mesh14/fluid_rod.e'
  []

  [fuel_rod]
    type = FileMeshGenerator
    file = 'mesh/mesh14/fuel_rod_square.e'
  []

  [pmg]
    type = PatternedMeshGenerator
    inputs = 'fluid_rod fuel_rod'
    pattern = '0 0 0 0 ;
               0 1 1 0 ;
               0 1 1 0 ;
               0 0 0 0
               '
  []

  [mesh_extruded]
    type = AdvancedExtruderGenerator
    input = pmg
    direction = '0 0 1'
    #heights = '0.05 0.128 0.05'
    #num_layers = '22 56 22'
    heights = '0.00223 0.00223 0.00223'
    num_layers = '1 1 1'
    bottom_boundary = 5
    top_boundary = 6
    subdomain_swaps = '1 0 2 0 3 0 4 0;
                       1 1 2 2 3 3 4 0;
                       1 0 2 0 3 0 4 0
                      '
  []

  [mesh]
    type = SideSetsBetweenSubdomainsGenerator
    input = 'mesh_extruded'
    paired_block = '3 1 2'
    primary_block = '0 0 0'
    new_boundary = 'outer'
  []

  [rename_boundaries]
    type = RenameBoundaryGenerator
    input = mesh
    old_boundary = 'top bottom'
    new_boundary = 'front back'
  []

  [rename_boundaries2]
    type = RenameBoundaryGenerator
    input = rename_boundaries
    old_boundary = '5 6'
    new_boundary = 'bottom top'
  []
[]

[Variables]
  [vel_x]
    # x component of velocity
    type = INSFVVelocityVariable
    block = 0
  []

  [vel_y]
    # y component of velocity
    type = INSFVVelocityVariable
    block = 0
  []

  [vel_z]
    # z component of velocity
    type = INSFVVelocityVariable
    block = 0
  []

  [pressure]
    type = INSFVPressureVariable
    block = 0
  []

  [T]
    type = INSFVEnergyVariable
    block = 0
  []

  [lambda]
    family = SCALAR
    order = FIRST
    block = 0
  []
[]

[AuxVariables]
  [T_solid]
    type = MooseVariableFVReal
    initial_condition = ${T_cold}
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
    block = 0
  []

  [mean_zero_pressure]
    type = FVIntegralValueConstraint
    variable = pressure
    lambda = lambda
    block = 0
  []

  [u_time]
    type = INSFVMomentumTimeDerivative
    rho = ${rho_fluid}
    momentum_component = 'x'
    variable = vel_x
    block = 0
  []

  [u_advection]
    type = INSFVMomentumAdvection
    variable = vel_x
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    rho = ${rho_fluid}
    momentum_component = 'x'
    block = 0
  []

  [u_viscosity]
    type = INSFVMomentumDiffusion
    variable = vel_x
    mu = ${mu}
    momentum_component = 'x'
    block = 0
  []

  [u_pressure]
    type = INSFVMomentumPressure
    variable = vel_x
    momentum_component = 'x'
    pressure = pressure
    block = 0
  []

  [u_buoyancy]
    # Natural convection term
    type = INSFVMomentumBoussinesq
    variable = vel_x
    T_fluid = T
    gravity = '0 0 -1'
    rho = ${rho_fluid}
    ref_temperature = ${T_cold}
    momentum_component = 'x'
    block = 0
  []

  [u_gravity]
    # Natural convection term
    type = INSFVMomentumGravity
    variable = vel_x
    gravity = '0 0 -1'
    rho = ${rho_fluid}
    momentum_component = 'x'
    block = 0
  []

  [v_time]
    type = INSFVMomentumTimeDerivative
    rho = ${rho_fluid}
    momentum_component = 'y'
    variable = vel_y
    block = 0
  []

  [v_advection]
    type = INSFVMomentumAdvection
    variable = vel_y
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    rho = ${rho_fluid}
    momentum_component = 'y'
    block = 0
  []

  [v_viscosity]
    type = INSFVMomentumDiffusion
    variable = vel_y
    mu = ${mu}
    momentum_component = 'y'
    block = 0
  []

  [v_pressure]
    type = INSFVMomentumPressure
    variable = vel_y
    momentum_component = 'y'
    pressure = pressure
    block = 0
  []

  [v_buoyancy]
    # natural convection term
    type = INSFVMomentumBoussinesq
    variable = vel_y
    T_fluid = T
    gravity = '0 0 -1'
    rho = ${rho_fluid}
    ref_temperature = ${T_cold}
    momentum_component = 'y'
    block = 0
  []

  [v_gravity]
    # natural convection term
    type = INSFVMomentumGravity
    variable = vel_y
    gravity = '0 0 -1'
    rho = ${rho_fluid}
    momentum_component = 'y'
    block = 0
  []

  [w_time]
    type = INSFVMomentumTimeDerivative
    rho = ${rho_fluid}
    momentum_component = 'z'
    variable = vel_z
    block = 0
  []

  [w_advection]
    type = INSFVMomentumAdvection
    variable = vel_z
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    rho = ${rho_fluid}
    momentum_component = 'z'
    block = 0
  []

  [w_viscosity]
    type = INSFVMomentumDiffusion
    variable = vel_z
    mu = ${mu}
    momentum_component = 'z'
    block = 0
  []

  [w_pressure]
    type = INSFVMomentumPressure
    variable = vel_z
    momentum_component = 'z'
    pressure = pressure
    block = 0
  []

  [w_buoyancy]
    # natural convection term
    type = INSFVMomentumBoussinesq
    variable = vel_z
    T_fluid = T
    gravity = '0 0 -1'
    rho = ${rho_fluid}
    ref_temperature = ${T_cold}
    momentum_component = 'z'
    block = 0
  []

  [w_gravity]
    # natural convection term
    type = INSFVMomentumGravity
    variable = vel_z
    gravity = '0 0 -1'
    rho = ${rho_fluid}
    momentum_component = 'z'
    block = 0
  []

  [temp_time]
    type = INSFVEnergyTimeDerivative
    rho = ${rho_fluid}
    cp = ${cp_fluid}
    variable = T
    block = 0
  []

  [temp_conduction]
    type = FVDiffusion
    coeff = 'k_fluid'
    variable = T
    block = 0
  []

  [temp_advection]
    type = INSFVEnergyAdvection
    variable = T
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    block = 0
  []
[]

[FVBCs]
  [no_slip_x]
    type = INSFVNoSlipWallBC
    variable = vel_x
    boundary = 'left right top bottom front back outer'
    function = 0
  []

  [no_slip_y]
    type = INSFVNoSlipWallBC
    variable = vel_y
    boundary = 'left right top bottom front back outer'
    function = 0
  []

  [no_slip_z]
    type = INSFVNoSlipWallBC
    variable = vel_z
    boundary = 'left right top bottom front back outer'
    function = 0
  []

  [T_cold_boundary]
    type = FVDirichletBC
    variable = T
    boundary = 'left right top bottom front back'
    value = ${T_cold}
  []

  [cylinder_interface]
    type = FVFunctorConvectiveHeatFluxBC
    T_bulk = T
    T_solid = T_solid
    boundary = outer
    heat_transfer_coefficient = ${h_interface}
    variable = T
    is_solid = false
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

  [vel_z]
    type = ConstantIC
    variable = vel_z
    value = 0
  []
[]

[Materials]
  # Associate material property values with required names
  [functor_constants_fluid]
    type = ADGenericFunctorMaterial
    prop_names = 'alpha_b cp k_fluid'
    prop_values = '${alpha} ${cp_fluid} ${k_fluid}'
  []

  [density_fluid]
    # needed for advection kernel
    type = INSFVEnthalpyMaterial
    temperature = 'T'
    rho = ${rho_fluid}
  []
[]

[Executioner]
  type = Transient
  scheme = implicit-euler
  end_time = 60
  #end_time = '${units 365 day -> s}'
  #dtmax = '${units 10 day -> s}'
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = '${units 1.5 s}'
  []

  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_factor_shift_type -snes_linesearch_damping'
  petsc_options_value = 'lu NONZERO 1.0'
  line_search = none
  nl_rel_tol = 1e-08
  nl_abs_tol = 1e-10
  automatic_scaling = true
  fixed_point_max_its = 30
  fixed_point_abs_tol = 1e-10
  fixed_point_rel_tol = 1e-8
[]

[Outputs]
  exodus = true
[]

[MultiApps]
  [fuel_rod]
    type = TransientMultiApp
    #positions = '${pitch} -${pitch} 0.05
    #${fparse 2 * ${pitch}} -${pitch} 0.05
    #${pitch} -${fparse 2 * ${pitch}} 0.05
    #${fparse 2 * ${pitch}} -${fparse 2 * ${pitch}} 0.05
    #'
    positions = '${pitch} -${pitch} 0.00223
    ${fparse 2 * ${pitch}} -${pitch} 0.00223
    ${pitch} -${fparse 2 * ${pitch}} 0.00223
    ${fparse 2 * ${pitch}} -${fparse 2 * ${pitch}} 0.00223
    '
    input_files = 'child_fuel_rod.i'
    execute_on = TIMESTEP_BEGIN
    output_in_position = true
    sub_cycling = false

    cli_args = T_cold=${T_cold};h_interface=${h_interface};mesh_path=${mesh_path}
  []
[]

[Transfers]
  [push_T]
    type = MultiAppGeneralFieldNearestNodeTransfer
    to_multi_app = fuel_rod
    source_variable = T
    variable = T_fluid
  []

  [pull_T]
    type = MultiAppGeneralFieldNearestNodeTransfer
    from_multi_app = fuel_rod
    source_variable = sub_T
    variable = T_solid
  []
[]
