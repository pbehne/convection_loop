#####################################################################
# material properties assuming fluid = He @ STP
#####################################################################
mu = '${units 1.96e-3 Pa*s}' # Exponent should be -5, but run into convergence issues (turbulence)
rho_fluid = '${units 1.78e-4 g/cm^3 -> kg/m^3}'
k_fluid = '${units 0.02 W/(m*K)}'
cp_fluid = '${units 5.193 J/(kg*K)}'
T_cold = '${units 293 K}'
#h_interface = '${units 20 W/(m^2*K)}' # convection coefficient at solid/fluid interface
alpha = '${units ${fparse 1/T_cold} K^(-1)}' # natural convection coefficient = 1/T assuming ideal gas

# Geometric settings
pitch = '${units 0.032 m}'
half_pitch = '${fparse 0.5 * ${pitch}}'

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
    #w = vel_z
    pressure = pressure
  []
[]

[Mesh]

  [fluid_rod]
    type = GeneratedMeshGenerator
    dim = 2

    xmin = -${half_pitch}
    xmax = ${half_pitch}
    ymin = -${half_pitch}
    ymax = ${half_pitch}

    nx = 14
    ny = 14
  []

  [fuel_rod]
    type = ConcentricCircleMeshGenerator
    num_sectors = 4
    radii = '0.00918 0.00934 0.01054' # meters
    rings = '4 2 3 4'
    has_outer_square = on
    pitch = ${pitch}
    preserve_volumes = true
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
[]

[Variables]
  [vel_x]
    # x component of velocity
    type = INSFVVelocityVariable
  []

  [vel_y]
    # y component of velocity
    type = INSFVVelocityVariable
  []

  #[vel_z]
  #  # z component of velocity
  #  type = INSFVVelocityVariable
  #[]

  [pressure]
    type = INSFVPressureVariable
  []

  [T]
    type = INSFVEnergyVariable
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
  []

  [mean_zero_pressure]
    type = FVIntegralValueConstraint
    variable = pressure
    lambda = lambda
  []

  [u_time]
    type = INSFVMomentumTimeDerivative
    rho = ${rho_fluid}
    momentum_component = 'x'
    variable = vel_x
  []

  [u_advection]
    type = INSFVMomentumAdvection
    variable = vel_x
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    rho = ${rho_fluid}
    momentum_component = 'x'
  []

  [u_viscosity]
    type = INSFVMomentumDiffusion
    variable = vel_x
    mu = ${mu}
    momentum_component = 'x'
  []

  [u_pressure]
    type = INSFVMomentumPressure
    variable = vel_x
    momentum_component = 'x'
    pressure = pressure
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
  []

  [u_gravity]
    # Natural convection term
    type = INSFVMomentumGravity
    variable = vel_x
    gravity = '0 -1 0'
    rho = ${rho_fluid}
    momentum_component = 'x'
  []

  [v_time]
    type = INSFVMomentumTimeDerivative
    rho = ${rho_fluid}
    momentum_component = 'y'
    variable = vel_y
  []

  [v_advection]
    type = INSFVMomentumAdvection
    variable = vel_y
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    rho = ${rho_fluid}
    momentum_component = 'y'
  []

  [v_viscosity]
    type = INSFVMomentumDiffusion
    variable = vel_y
    mu = ${mu}
    momentum_component = 'y'
  []

  [v_pressure]
    type = INSFVMomentumPressure
    variable = vel_y
    momentum_component = 'y'
    pressure = pressure
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
  []

  [v_gravity]
    # natural convection term
    type = INSFVMomentumGravity
    variable = vel_y
    gravity = '0 -1 0'
    rho = ${rho_fluid}
    momentum_component = 'y'
  []

  #[w_time]
  #  type = INSFVMomentumTimeDerivative
  #  rho = ${rho_fluid}
  #  momentum_component = 'z'
  #  variable = vel_z
  #[]

  #[w_advection]
  #  type = INSFVMomentumAdvection
  #  variable = vel_z
  #  velocity_interp_method = ${velocity_interp_method}
  #  advected_interp_method = ${advected_interp_method}
  #  rho = ${rho_fluid}
  #  momentum_component = 'z'
  #[]

  #[w_viscosity]
  #  type = INSFVMomentumDiffusion
  #  variable = vel_z
  #  mu = ${mu}
  #  momentum_component = 'z'
  #[]

  #[w_pressure]
  #  type = INSFVMomentumPressure
  #  variable = vel_z
  #  momentum_component = 'z'
  #  pressure = pressure
  #[]

  #[w_buoyancy]
  #  # natural convection term
  #  type = INSFVMomentumBoussinesq
  #  variable = vel_z
  #  T_fluid = T
  #  gravity = '0 -1 0'
  #  rho = ${rho_fluid}
  #  ref_temperature = ${T_cold}
  #  momentum_component = 'z'
  #[]

  #[w_gravity]
  #  # natural convection term
  #  type = INSFVMomentumGravity
  #  variable = vel_z
  #  gravity = '0 -1 0'
  #  rho = ${rho_fluid}
  #  momentum_component = 'z'
  #[]

  [temp_time]
    type = INSFVEnergyTimeDerivative
    rho = ${rho_fluid}
    cp = ${cp_fluid}
    variable = T
  []

  [temp_conduction]
    type = FVDiffusion
    coeff = 'k_fluid'
    variable = T
  []

  [temp_advection]
    type = INSFVEnergyAdvection
    variable = T
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
  []
[]

[FVBCs]
  # Note that left boundary of fluid domain is 'solid_fluid_interface'
  [no_slip_x]
    type = INSFVNoSlipWallBC
    variable = vel_x
    boundary = 'left right top bottom back'
    function = 0
  []
  [lid]
    type = INSFVNoSlipWallBC
    variable = vel_x
    boundary = 'front'
    function = 1
  []

  [no_slip_y]
    type = INSFVNoSlipWallBC
    variable = vel_y
    boundary = 'left right top bottom front back'
    function = 0
  []

  #[no_slip_z]
  #  type = INSFVNoSlipWallBC
  #  variable = vel_z
  #  boundary = 'left right top bottom front back'
  #  function = 0
  #[]

  [T_cold_boundary]
    type = FVDirichletBC
    variable = T
    boundary = 'left right top bottom front back'
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

  #[vel_z]
  #  type = ConstantIC
  #  variable = vel_z
  #  value = 0
  #[]
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
  #end_time = 10
  dt = 1
  steady_state_detection = true
  steady_state_tolerance = 1e-10
  #end_time = '${units 365 day -> s}'
  #dtmax = '${units 10 day -> s}'
  #[TimeStepper]
  #  type = IterationAdaptiveDT
  #  dt = '${units 1 day -> s}'
  #[]

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
