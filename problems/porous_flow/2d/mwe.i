[Mesh]
  [cmg]
    type = CartesianMeshGenerator
    dim = 2
    dx = '1.0'
    dy = '1.0'
    ix = '10'
    iy = '10'
  []
[]

[Variables]
  [Temperature]
    type = INSFVEnergyVariable
  []
[]

###################################################
# Set up conservation equations to solve
###################################################

[FVKernels]
  [temp_time]
    type = INSFVEnergyTimeDerivative
    rho = 1.0
    cp = 1.0
    variable = Temperature
  []

  [temp_conduction]
    type = FVDiffusion
    coeff = 'k'
    variable = Temperature
  []

  [heat_source]
    # Spent fuel volumetric heat source in solid domain
    type = FVBodyForce
    variable = Temperature
    function = 1.0
  []
[]

[FVBCs]
  [T_cold_boundary]
    type = FVDirichletBC
    variable = Temperature
    boundary = 'left right top bottom'
    value = 0
  []
[]

[ICs]
  [temp_ic]
    type = ConstantIC
    variable = Temperature
    value = 0
  []
[]

[Materials]
  # Associate material property values with required names
  [functor_constants_fluid]
    type = ADGenericFunctorMaterial
    prop_names = 'cp k'
    prop_values = '1.0 1.0'
  []
[]

[Executioner]
  type = Transient
  end_time = 10.0
  dt = 1.0

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