# Data sources
database(
    thermoLibraries = ['KlippensteinH2O2','primaryThermoLibrary','thermo_DFT_CCSDTF12_BAC','DFT_QCI_thermo','FFCM1(-)','CHN','GRI-Mech3.0-N'],
    reactionLibraries = [('KlippensteinH2O2',False),('FFCM1(-)',False),('Nitrogen_Dean_and_Bozzelli',False)],
    seedMechanisms = [],
    kineticsDepositories = ['training'],
    kineticsFamilies = 'default',
    kineticsEstimator = 'rate rules',
)

# List of species
species(
    label='NC',
    reactive=True,
    structure=SMILES("NC"),
)

species(
    label='O2',
    reactive=True,
    structure=SMILES("[O][O]"),
)

species(
    label='Ar',
    reactive=False,
    structure=adjacencyList(
                """
                1 Ar u0 p4 c0
                """),
)

# Reaction systems
simpleReactor(
    temperature=(1500,'K'),
    pressure=(1,'atm'),
    initialMoleFractions={
        "NC": 0.0005,
		"O2": 0.002,
		"Ar": 0.9975,
    },
    terminationTime=(0.002,'s'),
)

simulator(
    atol=1e-16,
    rtol=1e-8,
)

model(
    toleranceKeepInEdge=0,
    toleranceMoveToCore=0.2,
    toleranceInterruptSimulation=0.2,
    maximumEdgeSpecies=300000
)

options(
    units='si',
    generateOutputHTML=False,
    generatePlots=False,
    saveEdgeSpecies=True,
    saveSimulationProfiles=False,
	saveRestartPeriod=None,
)

generatedSpeciesConstraints(
    allowed=['input species','seed mechanisms','reaction libraries'],
    maximumCarbonAtoms=2,
    maximumOxygenAtoms=2,
    maximumNitrogenAtoms=2,
    maximumSiliconAtoms=0,
    maximumSulfurAtoms=0,
    maximumHeavyAtoms=3,
    maximumRadicalElectrons=2,
    allowSingletO2=False,
)