
options(
    title='NCC',
    tolerance=0.1
)

observable(
    label='NCC',
    structure=SMILES("NCC"),
)

observable(
    label='OH',
    structure=SMILES("[OH]"),
)

observable(
    label='NH2',
    structure=SMILES("[NH2]"),
)

species(
    label='O2',
    structure=SMILES("[O][O]"),
)

species(
    label='Ar',
    structure=adjacencyList('1 Ar u0 p4 c0'),
)

reactorSetups(
    reactorTypes=['IdealGasReactor'],
    terminationTimes=([0.002],'s'),
    initialMoleFractionsList=[{
        "NC": 0.0005,
        "O2": 0.002,
        "Ar": 0.9975,
    }],
    temperatures=([1500],'K'),
    pressures=([1.],'atm'),
)
