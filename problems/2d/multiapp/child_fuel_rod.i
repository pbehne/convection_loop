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
    block = 'clad_block'
  []
[]

###################################################
# Set up conservation equations to solve
###################################################

[Kernels]
  [temp_time]
    type = HeatConductionTimeDerivative
    variable = sub_T
    density_name = rho
    specific_heat = cp
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
    block = 'fuel_block'
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
    block = 'fuel_block'
  []

  [gap_mat]
    type = GenericFunctionMaterial
    prop_names = 'cp k rho'
    prop_values = '${cp_gap} ${k_gap} ${rho_gap}'
    block = 'gap_block'
  []

  [steel_mat]
    type = GenericFunctionMaterial
    prop_names = 'cp k rho'
    prop_values = '${cp_steel} ${k_steel} ${rho_steel}'
    block = 'clad_block'
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
