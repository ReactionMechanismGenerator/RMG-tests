# Catalytic combustion of methane on Pt
# Tests surface chemistry 

#Data sources
database(
    thermoLibraries=['surfaceThermoPt', 'primaryThermoLibrary', 'thermo_DFT_CCSDTF12_BAC','DFT_QCI_thermo'],
    reactionLibraries = [('Surface/CPOX_Pt/Deutschmann2006', False),('BurkeH2O2inN2',False),('FFCM1(-)',False)],
    seedMechanisms = [],
    kineticsDepositories = ['training'],
    kineticsFamilies =['surface','default'],
    kineticsEstimator = 'rate rules',
)

catalystProperties(
    bindingEnergies = {
                        'H': (-2.479, 'eV/molecule'),
                        'O': (-3.586, 'eV/molecule'),
                        'C': (-6.750, 'eV/molecule'),
                        'N': (-4.352, 'eV/molecule'),
                    },
    surfaceSiteDensity=(2.72e-9, 'mol/cm^2'),
)

generatedSpeciesConstraints(
    allowed=['reaction libraries'],
)


# List of species
species(
    label='X',
    reactive=True,
    structure=adjacencyList("1 X u0"),
)

species(
    label='CH4',
    reactive=True,
    structure=SMILES("[CH4]"),
)
species(
   label='O2',
   reactive=True,
   structure=adjacencyList(
       """
1 O u1 p2 c0 {2,S}
2 O u1 p2 c0 {1,S}
"""),
)

species(
    label='N2',
    reactive=False,
    structure=SMILES("N#N"),
)


#----------

surfaceReactor(
    temperature=(800,'K'),
    initialPressure=(1.0, 'bar'),
    initialGasMoleFractions={
        "CH4": 0.0500,
        "O2": 0.1995,
        "N2": 0.7505,
    },
    initialSurfaceCoverages={
        "X": 1.0,
    },
    surfaceVolumeRatio=(1.0e4, 'm^-1'),
    terminationConversion = { "CH4":0.9,}
)

surfaceReactor(
    temperature=(1500,'K'),
    initialPressure=(1.0, 'bar'),
    initialGasMoleFractions={
        "CH4": 0.0500,
        "O2": 0.1995,
        "N2": 0.7505,
    },
    initialSurfaceCoverages={
        "X": 1.0,
    },
    surfaceVolumeRatio=(1.0e4, 'm^-1'),
    terminationConversion = { "CH4":0.9,}
)


surfaceReactor(
    temperature=(1750,'K'),
    initialPressure=(1.0, 'bar'),
    initialGasMoleFractions={
        "CH4": 0.0500,
        "O2": 0.1995,
        "N2": 0.7505,
    },
    initialSurfaceCoverages={
        "X": 1.0,
    },
    surfaceVolumeRatio=(1.0e4, 'm^-1'),
    terminationConversion = { "CH4":0.9,}
)



simulator(
    atol=1e-18,
    rtol=1e-12,
)

model(
    toleranceMoveToCore=0.01, 
    toleranceInterruptSimulation=0.1,
    maximumEdgeSpecies=100000
)

options(
    units='si',
    saveRestartPeriod=None,
    generateOutputHTML=False,
    generatePlots=False,
    saveEdgeSpecies=True,
    saveSimulationProfiles=True,
)

