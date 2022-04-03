# Data sources
database(
    thermoLibraries = ['BurkeH2O2','thermo_DFT_CCSDTF12_BAC','DFT_QCI_thermo','primaryNS','primaryThermoLibrary','SulfurGlarborgH2S','SulfurGlarborgMarshall'],
    reactionLibraries = ['primarySulfurLibrary','Sulfur/GlarborgH2S','Sulfur/GlarborgMarshall'],
    seedMechanisms = ['primaryH2O2'],
    kineticsDepositories = ['training'],
    kineticsFamilies = 'default',
    kineticsEstimator = 'rate rules',
)

# List of species
species(
    label='H2S',
    reactive=True,
    structure=SMILES("S"),
)

species(
    label='O2',
    reactive=True,
    structure=SMILES("[O][O]"),
)

species(
    label='N2',
    reactive=False,
    structure=SMILES("N#N"),
)

# Reaction systems
simpleReactor(
    temperature=(500,'K'),
    pressure=(30,'bar'),
    initialMoleFractions={
        "H2S": 0.000756,
		"O2": 0.001290,
		"N2": 0.997954,
    },
    terminationTime=(0.1,'s'),
)
simpleReactor(
    temperature=(900,'K'),
    pressure=(30,'bar'),
    initialMoleFractions={
        "H2S": 0.000756,
		"O2": 0.001290,
		"N2": 0.997954,
    },
    terminationTime=(0.1,'s'),
)

simulator(
    atol=1e-16,
    rtol=1e-8,
)

model(
    toleranceKeepInEdge=0,
    toleranceMoveToCore=0.1,
    toleranceInterruptSimulation=0.1,
    maximumEdgeSpecies=300000
)

#pressureDependence(
#        method='modified strong collision',
#        maximumGrainSize=(0.5,'kcal/mol'),
#        minimumNumberOfGrains=250,
#        temperatures=(298,2500,'K',25),
#        pressures=(0.1,50,'bar',25),
#        interpolation=('Chebyshev', 6, 4),
#        maximumAtoms=16,
#)

options(
    generateOutputHTML=False,
    generatePlots=False,
    saveEdgeSpecies=True,
    saveSimulationProfiles=False,
    saveRestartPeriod=None,
)

generatedSpeciesConstraints(
    allowed=['input species','seed mechanisms','reaction libraries'],
    maximumCarbonAtoms=0,
    maximumOxygenAtoms=4,
    maximumNitrogenAtoms=2,
    maximumSiliconAtoms=0,
    maximumSulfurAtoms=3,
    maximumHeavyAtoms=5,
    maximumRadicalElectrons=2,
    allowSingletO2=False,
)
