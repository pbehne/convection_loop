#####################################################################
# material properties
#####################################################################
rho_fuel = '${units 10.97 g/cm^3 -> kg/m^3}'
#rho_gap = '${units 1.78e-4 g/cm^3 -> kg/m^3}'
#rho_steel = '${units 7.85 g/cm^3 -> kg/m^3}'
k_fuel = '${units 10.2 W/(m*K)}'
#k_gap = '${units 0.02 W/(m*K)}'
#k_steel = '${units 45 W/(m*k)}'
cp_fuel = '${units 300 J/(kg*K)}'
#cp_gap = '${units 5.193 J/(kg*K)}'
#cp_steel = '${units 466 J/(kg*K)}'
T_cold = '${units 293 K}'
#h_interface = '${units 20 W/(m^2*K)}' # convection coefficient at solid/fluid interface
q_vol = '${units 100000 kW/m^3 -> W/m^3}' # Volumetric heat source amplitude

# TODO: add in He gap and clad w/ interfaces

# Geometric settings
pitch = '${units 0.032 m}'

[Mesh]
  [fuel_rod]
    type = ConcentricCircleMeshGenerator
    num_sectors = 6
    radii = '0.00918 0.00934 0.01054' # meters
    rings = '4 1 2'
    has_outer_square = false
    pitch = ${pitch}
    preserve_volumes = true
  []
[]

[Variables]
  [sub_T]
    type = INSFVEnergyVariable
  []
[]

[AuxVariables]
  [T_fluid]
    type = MooseVariableFVReal
    initial_condition = ${T_cold}
  []
[]

###################################################
# Set up conservation equations to solve
###################################################

[FVKernels]
  [temp_time]
    type = INSFVEnergyTimeDerivative
    rho = ${rho_fuel}
    cp = ${cp_fuel}
    variable = sub_T
  []

  [temp_conduction]
    type = FVDiffusion
    coeff = 'k_fuel'
    variable = sub_T
  []

  [heat_source]
    type = FVBodyForce
    variable = sub_T
    function = ${q_vol} #vol_heat_rate
    block = 1
  []
[]

[FVBCs]
  [cylinder_interface]
    type = FVFunctorDirichletBC
    variable = sub_T
    boundary = 'outer'
    functor = T_fluid_regular
  []
[]

[ICs]
  [temp_ic]
    type = ConstantIC
    variable = sub_T
    value = ${T_cold}
  []
[]

[Materials]
  # Associate material property values with required names
  [functor_constants_fuel]
    type = ADGenericFunctorMaterial
    prop_names = 'cp k_fuel'
    prop_values = '${cp_fuel} ${k_fuel}'
  []

  [ad_to_regular]
    type = FunctorADConverter
    ad_props_in = T_fluid
    reg_props_out = T_fluid_regular
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
