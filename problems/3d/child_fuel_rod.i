#####################################################################
# material properties
#####################################################################
rho_fuel = '${units 10.97 g/cm^3 -> kg/m^3}'
rho_gap = '${units 1.78e-4 g/cm^3 -> kg/m^3}'
rho_steel = '${units 7.85 g/cm^3 -> kg/m^3}'
k_fuel = '${units 10.2 W/(m*K)}'
k_gap = '${units 0.02 W/(m*K)}'
k_steel = '${units 45 W/(m*k)}'
cp_fuel = '${units 300 J/(kg*K)}'
cp_gap = '${units 5.193 J/(kg*K)}'
cp_steel = '${units 466 J/(kg*K)}'
q_vol = '${units 10000 kW/m^3 -> W/m^3}' # Volumetric heat source amplitude

[Mesh]
  [fuel_rod]
    type = FileMeshGenerator
    file = '${mesh_path}/fuel_rod.e'
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

  [mesh_extruded]
    type = AdvancedExtruderGenerator
    input = gap_clad_interface
    direction = '0 0 1'
    #heights = 0.128
    #num_layers = 56
    heights = 0.00223
    num_layers = 1
    bottom_boundary = 5
    top_boundary = 6
  []

  [rename_boundaries]
    type = RenameBoundaryGenerator
    input = mesh_extruded
    old_boundary = '5 6'
    new_boundary = 'outer outer'
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
    type = HeatConductionTimeDerivative
    variable = sub_T
    density_name = rho_fuel
    specific_heat = cp_fuel
    block = 1
  []

  [temp_conduction_fuel]
    type = HeatConduction
    variable = sub_T
    diffusion_coefficient = 'k_fuel'
    block = 1
  []

  [heat_source]
    type = HeatSource
    variable = sub_T
    function = ${q_vol} #vol_heat_rate
    block = 1
  []

  [temp_time_gap]
    type = HeatConductionTimeDerivative
    variable = sub_T
    density_name = rho_gap
    specific_heat = cp_gap
    block = 2
  []

  [temp_conduction_gap]
    type = HeatConduction
    variable = sub_T
    diffusion_coefficient = 'k_gap'
    block = 2
  []

  [temp_time_steel]
    type = HeatConductionTimeDerivative
    variable = sub_T
    density_name = rho_steel
    specific_heat = cp_steel
    block = 3
  []

  [temp_conduction_steel]
    type = HeatConduction
    variable = sub_T
    diffusion_coefficient = 'k_steel'
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
    prop_names = 'cp_fuel k_fuel rho_fuel'
    prop_values = '${cp_fuel} ${k_fuel} ${rho_fuel}'
    block = 1
  []

  [gap_mat]
    type = GenericFunctionMaterial
    prop_names = 'cp_gap k_gap rho_gap'
    prop_values = '${cp_gap} ${k_gap} ${rho_gap}'
    block = 2
  []

  [gap_steel]
    type = GenericFunctionMaterial
    prop_names = 'cp_steel k_steel rho_steel'
    prop_values = '${cp_steel} ${k_steel} ${rho_steel}'
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
