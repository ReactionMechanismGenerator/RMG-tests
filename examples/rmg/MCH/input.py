# Data sources
database(
    thermoLibraries = ['primaryThermoLibrary'],
    reactionLibraries = [],
    seedMechanisms = [],
    kineticsDepositories = ['training'],
    kineticsFamilies = 'default',
    kineticsEstimator = 'rate rules',
)

# List of species
species(
    label='MCH',
    reactive=True,
    structure=SMILES("CC1CCCCC1"),
)

species(
    label='O2',
    reactive=True,
    structure=adjacencyList(
        """
        multiplicity 3
        1 O u1 p2 c0 {2,S}
        2 O u1 p2 c0 {1,S}
        """),
)

species(
    label='N2',
    reactive=False,
    structure=InChI("InChI=1/N2/c1-2"),
)

# Reaction systems
simpleReactor(
    temperature=(1000,'K'),
    pressure=(20.0,'bar'),
    initialMoleFractions={
        "MCH": 0.01,
        "O2": 0.105,
        "N2": 0.885,
    },
    terminationConversion={
        'MCH': 0.95,
    },
    terminationTime=(100,'s'),
)

simulator(
    atol=1e-16,
    rtol=1e-8,
)

model(
    toleranceKeepInEdge=0.0,
    toleranceMoveToCore=0.1,
    toleranceInterruptSimulation=0.1,
    maximumEdgeSpecies=100000,
)

options(
    units='si',
    saveRestartPeriod=None,
    generateOutputHTML=False,
    generatePlots=False,
    saveEdgeSpecies=True,
    saveSimulationProfiles=True,
)

generatedSpeciesConstraints(
    allowed=['input species', 'seed mechanisms', 'reaction libraries'],
    maximumCarbonAtoms=7,
)
