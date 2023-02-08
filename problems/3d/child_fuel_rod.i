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
q_vol = '${units 2 kW/m^3 -> W/m^3}' # Volumetric heat source amplitude

# Geometric settings
pitch = '${units 0.032 m}'

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
    u = sub_vel_x
    v = sub_vel_y
    #w = sub_vel_z
    pressure = sub_pressure
  []
[]

[Mesh]

  [fuel_rod]
    type = ConcentricCircleMeshGenerator
    num_sectors = 6
    radii = '0.00918 0.00934 0.01054' # meters
    rings = '4 1 2 3'
    has_outer_square = true
    pitch = ${pitch}
    preserve_volumes = true
  []
[]

[Variables]
  [sub_vel_x]
    # x component of velocity
    type = INSFVVelocityVariable
  []

  [sub_vel_y]
    # y component of velocity
    type = INSFVVelocityVariable
  []

  #[sub_vel_z]
  #  # z component of velocity
  #  type = INSFVVelocityVariable
  #[]

  [sub_pressure]
    type = INSFVPressureVariable
  []

  [sub_T]
    type = INSFVEnergyVariable
  []

  [lambda]
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
    variable = sub_pressure
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    rho = ${rho_fluid}
  []

  [mean_zero_pressure]
    type = FVIntegralValueConstraint
    variable = sub_pressure
    lambda = lambda
  []

  [u_time]
    type = INSFVMomentumTimeDerivative
    rho = ${rho_fluid}
    momentum_component = 'x'
    variable = sub_vel_x
  []

  [u_advection]
    type = INSFVMomentumAdvection
    variable = sub_vel_x
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    rho = ${rho_fluid}
    momentum_component = 'x'
  []

  [u_viscosity]
    type = INSFVMomentumDiffusion
    variable = sub_vel_x
    mu = ${mu}
    momentum_component = 'x'
  []

  [u_pressure]
    type = INSFVMomentumPressure
    variable = sub_vel_x
    momentum_component = 'x'
    pressure = sub_pressure
  []

  [u_buoyancy]
    # Natural convection term
    type = INSFVMomentumBoussinesq
    variable = sub_vel_x
    T_fluid = sub_T
    gravity = '0 -1 0'
    rho = ${rho_fluid}
    ref_temperature = ${T_cold}
    momentum_component = 'x'
  []

  [u_gravity]
    # Natural convection term
    type = INSFVMomentumGravity
    variable = sub_vel_x
    gravity = '0 -1 0'
    rho = ${rho_fluid}
    momentum_component = 'x'
  []

  [v_time]
    type = INSFVMomentumTimeDerivative
    rho = ${rho_fluid}
    momentum_component = 'y'
    variable = sub_vel_y
  []

  [v_advection]
    type = INSFVMomentumAdvection
    variable = sub_vel_y
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    rho = ${rho_fluid}
    momentum_component = 'y'
  []

  [v_viscosity]
    type = INSFVMomentumDiffusion
    variable = sub_vel_y
    mu = ${mu}
    momentum_component = 'y'
  []

  [v_pressure]
    type = INSFVMomentumPressure
    variable = sub_vel_y
    momentum_component = 'y'
    pressure = sub_pressure
  []

  [v_buoyancy]
    # natural convection term
    type = INSFVMomentumBoussinesq
    variable = sub_vel_y
    T_fluid = sub_T
    gravity = '0 -1 0'
    rho = ${rho_fluid}
    ref_temperature = ${T_cold}
    momentum_component = 'y'
  []

  [v_gravity]
    # natural convection term
    type = INSFVMomentumGravity
    variable = sub_vel_y
    gravity = '0 -1 0'
    rho = ${rho_fluid}
    momentum_component = 'y'
  []

  #[w_time]
  #  type = INSFVMomentumTimeDerivative
  #  rho = ${rho_fluid}
  #  momentum_component = 'z'
  #  variable = sub_vel_z
  #[]

  #[w_advection]
  #  type = INSFVMomentumAdvection
  #  variable = sub_vel_z
  #  velocity_interp_method = ${velocity_interp_method}
  #  advected_interp_method = ${advected_interp_method}
  #  rho = ${rho_fluid}
  #  momentum_component = 'z'
  #[]

  #[w_viscosity]
  #  type = INSFVMomentumDiffusion
  #  variable = sub_vel_z
  #  mu = ${mu}
  #  momentum_component = 'z'
  #[]

  #[w_pressure]
  #  type = INSFVMomentumPressure
  #  variable = sub_vel_z
  #  momentum_component = 'z'
  #  pressure = sub_pressure
  #[]

  #[w_buoyancy]
  #  # natural convection term
  #  type = INSFVMomentumBoussinesq
  #  variable = sub_vel_z
  #  T_fluid = sub_T
  #  gravity = '0 -1 0'
  #  rho = ${rho_fluid}
  #  ref_temperature = ${T_cold}
  #  momentum_component = 'z'
  #[]

  #[w_gravity]
  #  # natural convection term
  #  type = INSFVMomentumGravity
  #  variable = sub_vel_z
  #  gravity = '0 -1 0'
  #  rho = ${rho_fluid}
  #  momentum_component = 'z'
  #[]

  [temp_time]
    type = INSFVEnergyTimeDerivative
    rho = ${rho_fluid}
    cp = ${cp_fluid}
    variable = sub_T
  []

  [temp_conduction]
    type = FVDiffusion
    coeff = 'k_fluid'
    variable = sub_T
  []

  [temp_advection]
    type = INSFVEnergyAdvection
    variable = sub_T
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
  []

  [heat_source]
    type = FVBodyForce
    variable = sub_T
    function = ${q_vol} #vol_heat_rate
    block = 1
  []
[]

[FVBCs]
  [no_slip_x]
    type = INSFVNoSlipWallBC
    variable = sub_vel_x
    boundary = 'left right bottom'
    function = 0
  []
  [lid]
    type = INSFVNoSlipWallBC
    variable = sub_vel_x
    boundary = 'top'
    function = 1
  []

  [no_slip_y]
    type = INSFVNoSlipWallBC
    variable = sub_vel_y
    boundary = 'left right top bottom'
    function = 0
  []

  #[no_slip_z]
  #  type = INSFVNoSlipWallBC
  #  variable = sub_vel_z
  #  boundary = 'left right top bottom front back'
  #  function = 0
  #[]

  [T_cold_boundary]
    type = FVDirichletBC
    variable = sub_T
    boundary = 'left right top bottom'
    value = ${T_cold}
  []
[]

[ICs]
  [temp_ic]
    type = ConstantIC
    variable = sub_T
    value = ${T_cold}
  []

  [sub_vel_x]
    type = ConstantIC
    variable = sub_vel_x
    value = 0
  []

  [sub_vel_y]
    type = ConstantIC
    variable = sub_vel_y
    value = 0
  []

  #[sub_vel_z]
  #  type = ConstantIC
  #  variable = sub_vel_z
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
    temperature = 'sub_T'
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

