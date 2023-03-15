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
q_vol = '${units 1100 kW/m^3 -> W/m^3}' # Volumetric heat source amplitude

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
    heights = '0.0012 0.00016 4.0 0.00016 0.0012'
    num_layers = '1 1 1750 1 1'
    bottom_boundary = 5
    top_boundary = 6
    subdomain_swaps = '1 3 2 3 3 3;
                       1 2 2 2 3 3;
                       1 1 2 2 3 3;
                       1 2 2 2 3 3;
                       1 3 2 3 3 3
                      '
  []

  [rename_boundaries]
    type = RenameBoundaryGenerator
    input = mesh_extruded
    old_boundary = '5 6'
    new_boundary = 'outer outer'
  []

  [rename_block_name]
    type = RenameBlockGenerator
    input = rename_boundaries
    old_block = '1 2 3'
    new_block = 'fuel_block gap_block clad_block'
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
    order = FIRST
    family = LAGRANGE
    initial_condition = ${T_cold}
  []
[]

###################################################
# Set up conservation equations to solve
###################################################

[Kernels]
  [temp_time]
    type = HeatConductionTimeDerivative
    variable = sub_T
    density_name = 'rho'
    specific_heat = 'cp'
  []

  [temp_conduction]
    type = HeatConduction
    variable = sub_T
    diffusion_coefficient = 'k'
  []

  [heat_source]
    type = HeatSource
    variable = sub_T
    function = ${q_vol} #vol_heat_rate
    block = fuel_block
  []
[]

[InterfaceKernels]
  [fuel_gap_conduction]
    type = InterfaceDiffusion
    variable = sub_T
    neighbor_var = sub_T
    boundary = fuel_gap_interface
    D = "k"
    D_neighbor = "k"
  []

  [gap_clad_conduction]
    type = InterfaceDiffusion
    variable = sub_T
    neighbor_var = sub_T
    boundary = gap_clad_interface
    D = "k"
    D_neighbor = "k"
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
    prop_names = 'cp k rho'
    prop_values = '${cp_fuel} ${k_fuel} ${rho_fuel}'
    block = fuel_block
  []

  [gap_mat]
    type = GenericFunctionMaterial
    prop_names = 'cp k rho'
    prop_values = '${cp_gap} ${k_gap} ${rho_gap}'
    block = gap_block
  []

  [gap_steel]
    type = GenericFunctionMaterial
    prop_names = 'cp k rho'
    prop_values = '${cp_steel} ${k_steel} ${rho_steel}'
    block = clad_block
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

  [pgraph]
    type = PerfGraphOutput
    execute_on = 'final'  # Default is "final"
    level = 2                     # Default is 1
    heaviest_branch = true        # Default is false
    heaviest_sections = 10        # Default is 0
  []
[]
