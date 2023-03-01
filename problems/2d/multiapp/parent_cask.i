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
mesh_path = "mesh/mesh22/"

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
    pressure = pressure
    block = '0 4'
  []
[]

[Mesh]

  [fluid_rod]
    type = FileMeshGenerator
    file = '${mesh_path}/fluid_rod.e'
  []

  [fuel_rod]
    type = FileMeshGenerator
    file = '${mesh_path}/fuel_rod_square.e'
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

  [mesh]
    type = SideSetsBetweenSubdomainsGenerator
    input = 'pmg'
    paired_block = '3'
    primary_block = '4'
    new_boundary = 'outer'
  []
[]

[Variables]
  [vel_x]
    # x component of velocity
    type = INSFVVelocityVariable
    block = '0 4'
  []

  [vel_y]
    # y component of velocity
    type = INSFVVelocityVariable
    block = '0 4'
  []

  [pressure]
    type = INSFVPressureVariable
    block = '0 4'
  []

  [T]
    type = INSFVEnergyVariable
    block = '0 4'
  []

  [lambda]
    family = SCALAR
    order = FIRST
    block = '0 4'
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
    block = '0 4'
  []

  [mean_zero_pressure]
    type = FVIntegralValueConstraint
    variable = pressure
    lambda = lambda
    block = '0 4'
  []

  [u_time]
    type = INSFVMomentumTimeDerivative
    rho = ${rho_fluid}
    momentum_component = 'x'
    variable = vel_x
    block = '0 4'
  []

  [u_advection]
    type = INSFVMomentumAdvection
    variable = vel_x
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    rho = ${rho_fluid}
    momentum_component = 'x'
    block = '0 4'
  []

  [u_viscosity]
    type = INSFVMomentumDiffusion
    variable = vel_x
    mu = ${mu}
    momentum_component = 'x'
    block = '0 4'
  []

  [u_pressure]
    type = INSFVMomentumPressure
    variable = vel_x
    momentum_component = 'x'
    pressure = pressure
    block = '0 4'
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
    block = '0 4'
  []

  [u_gravity]
    # Natural convection term
    type = INSFVMomentumGravity
    variable = vel_x
    gravity = '0 -1 0'
    rho = ${rho_fluid}
    momentum_component = 'x'
    block = '0 4'
  []

  [v_time]
    type = INSFVMomentumTimeDerivative
    rho = ${rho_fluid}
    momentum_component = 'y'
    variable = vel_y
    block = '0 4'
  []

  [v_advection]
    type = INSFVMomentumAdvection
    variable = vel_y
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    rho = ${rho_fluid}
    momentum_component = 'y'
    block = '0 4'
  []

  [v_viscosity]
    type = INSFVMomentumDiffusion
    variable = vel_y
    mu = ${mu}
    momentum_component = 'y'
    block = '0 4'
  []

  [v_pressure]
    type = INSFVMomentumPressure
    variable = vel_y
    momentum_component = 'y'
    pressure = pressure
    block = '0 4'
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
    block = '0 4'
  []

  [v_gravity]
    # natural convection term
    type = INSFVMomentumGravity
    variable = vel_y
    gravity = '0 -1 0'
    rho = ${rho_fluid}
    momentum_component = 'y'
    block = '0 4'
  []

  [temp_time]
    type = INSFVEnergyTimeDerivative
    rho = ${rho_fluid}
    cp = ${cp_fluid}
    variable = T
    block = '0 4'
  []

  [temp_conduction]
    type = FVDiffusion
    coeff = 'k_fluid'
    variable = T
    block = '0 4'
  []

  [temp_advection]
    type = INSFVEnergyAdvection
    variable = T
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    block = '0 4'
  []
[]

[FVBCs]
  [no_slip_x]
    type = INSFVNoSlipWallBC
    variable = vel_x
    boundary = 'left right top bottom outer'
    function = 0
  []

  [no_slip_y]
    type = INSFVNoSlipWallBC
    variable = vel_y
    boundary = 'left right top bottom outer'
    function = 0
  []

  [T_cold_boundary]
    type = FVDirichletBC
    variable = T
    boundary = 'left right top bottom'
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
  picard_rel_tol = 1e-8
[]

[Outputs]
  exodus = true
[]

[MultiApps]
  [fuel_rod]
    type = TransientMultiApp
    positions = '${pitch} -${pitch} 0
    ${fparse 2 * ${pitch}} -${pitch} 0
    ${pitch} -${fparse 2 * ${pitch}} 0
    ${fparse 2 * ${pitch}} -${fparse 2 * ${pitch}} 0
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
