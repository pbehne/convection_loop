#####################################################################
# material properties
#####################################################################
rho_fuel = '${units 10.97 g/cm^3 -> kg/m^3}'
rho_gap = '${units 1.78e-4 g/cm^3 -> kg/m^3}'
#rho_gap = ${rho_fuel}
rho_steel = '${units 7.85 g/cm^3 -> kg/m^3}'
#rho_steel = ${rho_fuel}
k_fuel = '${units 10.2 W/(m*K)}'
k_gap = '${units 0.02 W/(m*K)}'
#k_gap = ${k_fuel}
k_steel = '${units 45 W/(m*k)}'
#k_steel = ${k_fuel}
cp_fuel = '${units 300 J/(kg*K)}'
cp_gap = '${units 5.193 J/(kg*K)}'
#cp_gap = ${cp_fuel}
cp_steel = '${units 466 J/(kg*K)}'
#cp_steel = ${cp_fuel}
T_cold = '${units 293 K}'
h_interface = '${units 20 W/(m^2*K)}' # convection coefficient at solid/fluid interface
q_vol = '${units 10000 kW/m^3 -> W/m^3}' # Volumetric heat source amplitude

# TODO: add radiation accross gap

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

  [fuel_gap_interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = 'fuel_rod'
    paired_block = 1
    primary_block = 2
    new_boundary = 'fuel_gap_interface'
  []

  [gap_clad_interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = 'fuel_gap_interface'
    paired_block = 2
    primary_block = 3
    new_boundary = 'gap_clad_interface'
  []
[]

[Variables]
  [sub_T]
    order = FIRST
    family = LAGRANGE
  []
[]

[AuxVariables]
  [T_fluid]
    initial_condition = ${T_cold}
  []
[]

###################################################
# Set up conservation equations to solve
###################################################

[Kernels]
  [temp_time_fuel]
    type = CoefTimeDerivative
    variable = sub_T
    Coefficient = '${fparse rho_fuel * cp_fuel}'
    block = 1
  []

  [temp_conduction_fuel]
    type = MatDiffusion
    variable = sub_T
    diffusivity = 'k_fuel'
    block = 1
  []

  [heat_source]
    type = BodyForce
    variable = sub_T
    function = ${q_vol} #vol_heat_rate
    block = 1
  []

  [temp_time_gap]
    type = CoefTimeDerivative
    variable = sub_T
    Coefficient = '${fparse rho_gap * cp_gap}'
    block = 2
  []

  [temp_conduction_gap]
    type = MatDiffusion
    variable = sub_T
    diffusivity = 'k_gap'
    block = 2
  []

  [temp_time_steel]
    type = CoefTimeDerivative
    variable = sub_T
    Coefficient = '${fparse rho_steel * cp_steel}'
    block = 3
  []

  [temp_conduction_steel]
    type = MatDiffusion
    variable = sub_T
    diffusivity = 'k_steel'
    block = 3
  []
[]

[InterfaceKernels]
  [fuel_gap_conduction]
    type = InterfaceDiffusion
    variable = sub_T
    neighbor_var = sub_T
    boundary = fuel_gap_interface
    D = "k_fuel"
    D_neighbor = "k_gap"
  []

  [gap_clad_conduction]
    type = InterfaceDiffusion
    variable = sub_T
    neighbor_var = sub_T
    boundary = gap_clad_interface
    D = "k_gap"
    D_neighbor = "k_steel"
  []
[]

[BCs]
  [cylinder_interface]
    type = CoupledConvectiveHeatFluxBC
    variable = sub_T
    boundary = outer
    htc = ${h_interface}
    T_infinity = T_fluid
    alpha = 1
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
  [fuel_mat]
    type = GenericFunctionMaterial
    prop_names = 'cp_fuel k_fuel'
    prop_values = '${cp_fuel} ${k_fuel}'
    block = 1
  []

  [gap_mat]
    type = GenericFunctionMaterial
    prop_names = 'cp_gap k_gap'
    prop_values = '${cp_gap} ${k_gap}'
    block = 2
  []

  [gap_steel]
    type = GenericFunctionMaterial
    prop_names = 'cp_steel k_steel'
    prop_values = '${cp_gap} ${k_steel}'
    block = 3
  []
[]

[Executioner]
  type = Transient
  scheme = implicit-euler
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
[]

[Outputs]
  exodus = true
[]
