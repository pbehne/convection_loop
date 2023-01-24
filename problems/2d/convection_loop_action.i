mu = 1.1
rho = 1.1
k = 2e-0
cp = 1
q_hot = 100
T_cold = 1
#h_cv = 1.0

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    ymin = 0
    ymax = 5
    xmin = 0
    xmax = 1
    ny = 100
    nx = 20
  []

  #coord_type = RZ
  #rz_coord_axis = Y
[]

[AuxVariables]
  [porosity]
    type = MooseVariableFVReal
    initial_condition = 0.5
  []
  [alpha]
    type = MooseVariableFVReal
    initial_condition = 1e8
  []
[]

[Modules]
  [NavierStokesFV]
    compressibility = 'incompressible'
    porous_medium_treatment = true
    add_energy_equation = true
    boussinesq_approximation = true
    ambient_convection_alpha = 'alpha'
    ambient_temperature = ${T_cold}

    density = ${rho}
    dynamic_viscosity = ${mu}
    thermal_conductivity = ${k}
    specific_heat = ${cp}
    porosity = 'porosity'

    initial_velocity = '0 1 0'
    initial_pressure = 0.0
    initial_temperature = ${T_cold}

    wall_boundaries = 'left right bottom top'
    momentum_wall_types = 'noslip noslip noslip noslip'
    energy_wall_types = 'heatflux fixed-temperature fixed-temperature fixed-temperature'
    energy_wall_function = '${q_hot} ${T_cold} ${T_cold} ${T_cold}'

    pin_pressure = true
    pinned_pressure_type = average
    pinned_pressure_value = 1
  []
[]

[Executioner]
  type = Transient
  end_time = 3.0
  num_steps = 30
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_shift_type'
  petsc_options_value = 'lu NONZERO'
  line_search = none
  nl_rel_tol = 1e-8
  #nl_abs_tol = 1e-12
[]

[Outputs]
  exodus = true
  csv = true
[]
