# Tests nitrogen chemistry and the following functionalities:
# Filter reactions, Adding multiple species, Thermo pruning, Species constraints,
# Libraries and Seed, Rate ratio termination

database(
    thermoLibraries=['BurkeH2O2','thermo_DFT_CCSDTF12_BAC','NitrogenCurran','primaryNS','primaryThermoLibrary',
                     'DFT_QCI_thermo','Klippenstein_Glarborg2016','NOx2018','CHN'],
    reactionLibraries=['primaryNitrogenLibrary','NOx2018','Klippenstein_Glarborg2016','Nitrogen_Dean_and_Bozzelli',
                       'C2H4+O_Klipp2017'],
    seedMechanisms=['BurkeH2O2inArHe'],
    kineticsDepositories=['training'],
    kineticsFamilies='default',
    kineticsEstimator='rate rules',
)

species(
    label='NCC',
    reactive=True,
    structure=SMILES("NCC"),
)

species(
    label='O2',
    reactive=True,
    structure=SMILES("[O][O]"),
)

species(
    label='OH',
    reactive=True,
    structure=SMILES("[OH]"),
)

species(
    label='NH2',
    reactive=True,
    structure=SMILES("[NH2]"),
)

species(
    label='Ar',
    reactive=False,
    structure=adjacencyList('1 Ar u0 p4 c0'),
)

simpleReactor(
    temperature=(1428,'K'),
    pressure=(1.21,'atm'),
    initialMoleFractions={"NCC": 0.002, "Ar": 0.998},
    terminationTime=(0.0005,'s'),
    sensitivity=['NH2'],
    sensitivityThreshold=0.01
)

simpleReactor(
    temperature=(1441,'K'),
    pressure=(2.09,'atm'),
    initialMoleFractions={"NCC": 0.002, "O2": 0.008, "Ar": 0.99},
    terminationTime=(0.0005,'s'),
)

simpleReactor(
    temperature=(1399,'K'),
    pressure=(1.93,'atm'),
    initialMoleFractions={"NCC": 0.0005, "O2": 0.002, "Ar": 0.9975},
    terminationTime=(0.0025,'s'),
    sensitivity=['OH'],
    sensitivityThreshold=0.01
)

simulator(atol=1e-16, rtol=1e-8, sens_atol=1e-6, sens_rtol=1e-4)

model(
    toleranceKeepInEdge=0,
    toleranceMoveToCore=0.02,
    toleranceInterruptSimulation=0.02,
    toleranceThermoKeepSpeciesInEdge=0.5,
    maximumEdgeSpecies=300000,
    maxNumObjsPerIter=5,
    terminateAtMaxObjects=True,
    filterReactions=True,
)

pressureDependence(
    method='modified strong collision',
    maximumGrainSize=(0.5,'kcal/mol'),
    minimumNumberOfGrains=250,
    temperatures=(298,2500,'K',10),
    pressures=(0.1,10,'bar',10),
    interpolation=('Chebyshev', 6, 4),
    maximumAtoms=16)

options(
    units='si',
    saveEdgeSpecies=True,
)

generatedSpeciesConstraints(
    allowed=['input species','seed mechanisms','reaction libraries'],
    maximumCarbonAtoms=3,
    maximumOxygenAtoms=2,
    maximumNitrogenAtoms=2,
    maximumSiliconAtoms=0,
    maximumSulfurAtoms=0,
    maximumHeavyAtoms=3,
    maximumRadicalElectrons=2,
    allowSingletO2=False,
)
