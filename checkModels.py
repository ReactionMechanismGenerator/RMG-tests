#!/usr/bin/env python
# encoding: utf-8

################################################################################
#
#   RMG - Reaction Mechanism Generator
#
#   Copyright (c) 2009-2011 by the RMG Team (rmg_dev@mit.edu)
#
#   Permission is hereby granted, free of charge, to any person obtaining a
#   copy of this software and associated documentation files (the 'Software'),
#   to deal in the Software without restriction, including without limitation
#   the rights to use, copy, modify, merge, publish, distribute, sublicense,
#   and/or sell copies of the Software, and to permit persons to whom the
#   Software is furnished to do so, subject to the following conditions:
#
#   The above copyright notice and this permission notice shall be included in
#   all copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
#   DEALINGS IN THE SOFTWARE.
#
################################################################################

import sys
import os
import os.path
import math

import logging
import argparse

from rmgpy.tools.diff_models import execute

def parseCommandLineArguments():
        
    
    parser = argparse.ArgumentParser()
    
    parser.add_argument('name', metavar='NAME', type=str, nargs=1,
        help='Name of test target model')
    parser.add_argument('chemkin', metavar='CHEMKIN', type=str, nargs=1,
        help='the Chemkin file of the tested model')
    parser.add_argument('speciesDict', metavar='SPECIESDICT', type=str, nargs=1,
        help='the species dictionary file of the tested model')
    
    args = parser.parse_args()

    return args

def main():
    """
    Driver function that parses command line arguments and passes them to the execute function.
    """
    args = parseCommandLineArguments()

    name = args.name[0]
    initializeLog(logging.WARNING, name + '.log')
    chemkin = os.path.join(os.getcwd(), args.chemkin[0])
    speciesDict = os.path.join(os.getcwd(), args.speciesDict[0])

    check(name, chemkin, speciesDict)

def check(name, chemkin, speciesDict):
    """
    Compare the provided chemkin model to the
    default chemkin model.
    """

    filename_chemkin = os.path.split(chemkin)[-1]
    filename_spcDict = os.path.split(speciesDict)[-1]

    folder = os.path.join(os.getcwd(),'testing/check/', name)
    chemkinOrig = os.path.join(folder,filename_chemkin)
    speciesDictOrig = os.path.join(folder,filename_spcDict)

    kwargs = {
        'wd': os.getcwd(),
        'web': True,
        }

    thermo, thermoOrig = None, None
    commonSpecies, uniqueSpeciesTest, uniqueSpeciesOrig, commonReactions, uniqueReactionsTest, uniqueReactionsOrig = \
    execute(chemkin, speciesDict, thermo, chemkinOrig, speciesDictOrig, thermoOrig, **kwargs)

    errorModel = checkModel(commonSpecies, uniqueSpeciesTest, uniqueSpeciesOrig, commonReactions, uniqueReactionsTest, uniqueReactionsOrig)

    errorSpecies = checkSpecies(commonSpecies, uniqueSpeciesTest, uniqueSpeciesOrig)

    errorReactions = checkReactions(commonReactions, uniqueReactionsTest, uniqueReactionsOrig)

def checkModel(commonSpecies, uniqueSpeciesTest, uniqueSpeciesOrig, commonReactions, uniqueReactionsTest, uniqueReactionsOrig):
    """
    Compare the species and reaction count of both models.
    """

    testModelSpecies = len(commonSpecies) + len(uniqueSpeciesTest)
    origModelSpecies = len(commonSpecies) + len(uniqueSpeciesOrig)

    logging.error('Test model has {} species.'.format(testModelSpecies))
    logging.error('Original model has {} species.'.format(origModelSpecies))

    testModelRxns = len(commonReactions) + len(uniqueReactionsTest)
    origModelRxns = len(commonReactions) + len(uniqueReactionsOrig)
    logging.error('Test model has {} reactions.'.format(testModelRxns))
    logging.error('Original model has {} reactions.'.format(origModelRxns))

    return (testModelSpecies != origModelSpecies) or (testModelRxns != origModelRxns)

def checkSpecies(commonSpecies, uniqueSpeciesTest, uniqueSpeciesOrig):

    error = False

    # check for unique species in one of the models:
    if uniqueSpeciesOrig:
        error = True
        logging.error(
            'The original model has {} species that the tested model does not have.'
            .format(len(uniqueSpeciesOrig))
            )
        printSpecies(uniqueSpeciesOrig)

    if uniqueSpeciesTest:
        error = True
        logging.error(
            'The tested model has {} species that the original model does not have.'
            .format(len(uniqueSpeciesTest))
            )
        printSpecies(uniqueSpeciesTest)

    # check for different thermo among common species::
    if commonSpecies:
        for spec1, spec2 in commonSpecies:
            logging.info('    {0!s}'.format(spec1))
            if spec1.thermo and spec2.thermo:
                if not spec1.thermo.isIdenticalTo(spec2.thermo):
                    error = True
                    logging.error('Non-identical thermo for tested {} and original species {}.'
                        .format(spec1.label, spec2.label)
                    )
                    printThermo(spec1)
                    printThermo(spec2)

    return error

def checkReactions(commonReactions, uniqueReactionsTest, uniqueReactionsOrig):

    error = False

    # check for unique reactions in one of the models:
    if uniqueReactionsOrig:
        error = True
        
        logging.error(
            'The original model has {} reactions that the tested model does not have.'
            .format(len(uniqueReactionsOrig))
            )
        
        printReactions(uniqueReactionsOrig)

    if uniqueReactionsTest:
        error = True
        
        logging.error(
            'The tested model has {} reactions that the original model does not have.'
            .format(len(uniqueReactionsTest))
            )

        printReactions(uniqueReactionsTest)

    if commonReactions:
        for rxn1, rxn2 in commonReactions:
            logging.info('    {0!s}'.format(rxn1))
            if rxn1.kinetics and rxn2.kinetics:
                if not rxn1.kinetics.isIdenticalTo(rxn2.kinetics):
                    error = True

                    logging.error('Non-identical kinetics for\ntested {}\nand original {} reaction.'
                        .format(rxn1, rxn2)
                        )

                    printKinetics(rxn1)
                    printKinetics(rxn2)

    return error

def printReactions(reactions):
    """

    """

    for rxn in reactions:
        logging.error(
            'rxn: {}'.format(rxn)
            )

def printSpecies(spcs):
    """

    """

    for spc in spcs:
        logging.error(
            'spc: {}'.format(spc)
            )        

def printKinetics(rxn):
    """

    """
    logging.error('        k(300K,1bar) k(400K,1bar) k(500K,1bar) k(600K,1bar) k(800K,1bar) k(1000K,1bar) k(1500K,1bar) k(2000K,1bar) ')
    logging.error('        {0:7.2f} {1:7.2f} {2:7.2f} {3:7.2f} {4:7.2f} {5:7.2f} {6:7.2f} {7:7.2f}'.format(
        math.log10(rxn.kinetics.getRateCoefficient(300, 1e5)),
        math.log10(rxn.kinetics.getRateCoefficient(400, 1e5)),
        math.log10(rxn.kinetics.getRateCoefficient(500, 1e5)),
        math.log10(rxn.kinetics.getRateCoefficient(600, 1e5)),
        math.log10(rxn.kinetics.getRateCoefficient(800, 1e5)),
        math.log10(rxn.kinetics.getRateCoefficient(1000, 1e5)),
        math.log10(rxn.kinetics.getRateCoefficient(1500, 1e5)),
        math.log10(rxn.kinetics.getRateCoefficient(2000, 1e5)),
    ))

def printThermo(spec):
    """

    """
    logging.error('        Hf(300K) S(300K) Cp(300K) Cp(400K) Cp(500K) Cp(600K) Cp(800K) Cp(1000K) Cp(1500K)')
    logging.error('        {0:7.2f} {1:7.2f} {2:7.2f} {3:7.2f} {4:7.2f} {5:7.2f} {6:7.2f} {7:7.2f} {8:7.2f}'.format(
        spec.thermo.getEnthalpy(300) / 4184.,
        spec.thermo.getEntropy(300) / 4.184,
        spec.thermo.getHeatCapacity(300) / 4.184,
        spec.thermo.getHeatCapacity(400) / 4.184,
        spec.thermo.getHeatCapacity(500) / 4.184,
        spec.thermo.getHeatCapacity(600) / 4.184,
        spec.thermo.getHeatCapacity(800) / 4.184,
        spec.thermo.getHeatCapacity(1000) / 4.184,
        spec.thermo.getHeatCapacity(1500) / 4.184,
    ))


def initializeLog(verbose, log_file_name='checkModels.log'):
    """
    Set up a logger for RMG to use to print output to stdout. The
    `verbose` parameter is an integer specifying the amount of log text seen
    at the console; the levels correspond to those of the :data:`logging` module.
    """
    # Create logger
    logger = logging.getLogger()
    logger.setLevel(verbose)

    # Create console handler and set level to debug; send everything to stdout
    # rather than stderr
    ch = logging.StreamHandler(sys.stdout)
    ch.setLevel(verbose)

    logging.addLevelName(logging.CRITICAL, 'Critical: ')
    logging.addLevelName(logging.ERROR, 'Error: ')
    logging.addLevelName(logging.WARNING, 'Warning: ')
    logging.addLevelName(logging.INFO, '')
    logging.addLevelName(logging.DEBUG, '')
    logging.addLevelName(1, '')

    # Create formatter and add to console handler
    formatter = logging.Formatter('%(levelname)s%(message)s')
    ch.setFormatter(formatter)

    # create file handler
    fh = logging.FileHandler(filename=log_file_name) #, backupCount=3)
    fh.setLevel(min(logging.DEBUG,verbose)) # always at least VERBOSE in the file
    fh.setFormatter(formatter)

    # remove old handlers!
    while logger.handlers:
        logger.removeHandler(logger.handlers[0])

    # Add console and file handlers to logger
    logger.addHandler(ch)
    logger.addHandler(fh)


if __name__ == '__main__':
    main()