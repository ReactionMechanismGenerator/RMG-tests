# Data sources
database(
    thermoLibraries = ['primaryThermoLibrary'],
    reactionLibraries = [], #['GRI-Mech3.0-N'],
    seedMechanisms = ['GRI-Mech3.0-N'],
    kineticsDepositories = ['training'],
    kineticsFamilies = 'default',
    kineticsEstimator = 'rate rules',
)

# List of species
species(
    label='methane',
    reactive=True,
    structure=SMILES("C"),
)

species(
    label='nitrogen',
    reactive=True,
    structure=SMILES("N#N"),
)

species(
    label='oxygen',
    reactive=True,
    structure=SMILES("[O][O]"),
)

# Reaction systems
simpleReactor(
    temperature=(1350,'K'),
    pressure=(1.0,'bar'),
    initialMoleFractions={
        "methane": 0.25,
        "oxygen": 0.25,
        "nitrogen": 0.5,
    },
    terminationConversion={
        'methane': 0.5,
    },
    terminationTime=(1e6,'s'),
)

simulator(
    atol=1e-16,
    rtol=1e-8,
)

model(
    toleranceKeepInEdge=0.0,
    toleranceMoveToCore=0.8,
    toleranceInterruptSimulation=0.8,
    maximumEdgeSpecies=100000,
)

options(
    units='si',
    saveRestartPeriod=None,
    generateOutputHTML=True,
    generatePlots=False,
    saveEdgeSpecies=True,
    saveSimulationProfiles=True,
)

generatedSpeciesConstraints(
    #allows exceptions to the following restrictions
    allowed=['seed mechanisms'],
    maximumNitrogenAtoms=2
)
