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


import os

import os.path

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
    logger = logging.getLogger()
    logger.setLevel(logging.WARNING)

    name = args.name[0]
    chemkin = os.path.join(os.getcwd(), args.chemkin[0])
    speciesDict = os.path.join(os.getcwd(), args.speciesDict[0])

    check(name, chemkin, speciesDict)

def check(name, chemkin, speciesDict):
    """
    Compare the provided chemkin model to the
    default chemkin model.
    """

    folder = os.path.join(os.getcwd(),'testing/check/', name)
    chemkinOrig = os.path.join(folder,'chem_annotated.inp')
    speciesDictOrig = os.path.join(folder,'species_dictionary.txt')

    kwargs = {
        'wd': os.getcwd(),
        'web': True,
        }

    thermo, thermoOrig = None, None
    commonSpecies, uniqueSpeciesTest, uniqueSpeciesOrig, commonReactions, uniqueReactionsTest, uniqueReactionsOrig = \
    execute(chemkin, speciesDict, thermo, chemkinOrig, speciesDictOrig, thermoOrig, **kwargs)

    errorSpecies = checkSpecies(commonSpecies, uniqueSpeciesTest, uniqueSpeciesOrig)

    errorReactions = checkReactions(commonReactions, uniqueReactionsTest, uniqueReactionsOrig)

    if any([errorSpecies, errorReactions]):
        raise Exception

def checkSpecies(commonSpecies, uniqueSpeciesTest, uniqueSpeciesOrig):

    error = False

    # check for unique species in one of the models:
    if uniqueSpeciesOrig:
        error = True
        logging.error(
            'The original model has species that the tested model does not have: {}'
            .format(uniqueSpeciesOrig)
            )

    if uniqueSpeciesTest:
        error = True
        logging.error(
            'The tested model has species that the original model does not have: {}'
            .format(uniqueSpeciesTest)
            )

    # check for different thermo among common species::
    if commonSpecies:
        for spec1, spec2 in commonSpecies:
            logging.info('    {0!s}'.format(spec1))
            if spec1.thermo and spec2.thermo:
                if not spec1.thermo.isIdenticalTo(spec2.thermo):
                    error = True
                    logging.error('Non-identical thermo for tested and original species: {} \n {}'
                        .format(spec1, spec2))
                    logging.error('        {0:7.2f} {1:7.2f} {2:7.2f} {3:7.2f} {4:7.2f} {5:7.2f} {6:7.2f} {7:7.2f} {8:7.2f}'.format(
                        spec1.thermo.getEnthalpy(300) / 4184.,
                        spec1.thermo.getEntropy(300) / 4.184,
                        spec1.thermo.getHeatCapacity(300) / 4.184,
                        spec1.thermo.getHeatCapacity(400) / 4.184,
                        spec1.thermo.getHeatCapacity(500) / 4.184,
                        spec1.thermo.getHeatCapacity(600) / 4.184,
                        spec1.thermo.getHeatCapacity(800) / 4.184,
                        spec1.thermo.getHeatCapacity(1000) / 4.184,
                        spec1.thermo.getHeatCapacity(1500) / 4.184,
                    ))

                    logging.error('        {0:7.2f} {1:7.2f} {2:7.2f} {3:7.2f} {4:7.2f} {5:7.2f} {6:7.2f} {7:7.2f} {8:7.2f}'.format(
                        spec2.thermo.getEnthalpy(300) / 4184.,
                        spec2.thermo.getEntropy(300) / 4.184,
                        spec2.thermo.getHeatCapacity(300) / 4.184,
                        spec2.thermo.getHeatCapacity(400) / 4.184,
                        spec2.thermo.getHeatCapacity(500) / 4.184,
                        spec2.thermo.getHeatCapacity(600) / 4.184,
                        spec2.thermo.getHeatCapacity(800) / 4.184,
                        spec2.thermo.getHeatCapacity(1000) / 4.184,
                        spec2.thermo.getHeatCapacity(1500) / 4.184,
                    ))

    return error

def checkReactions(commonReactions, uniqueReactionsTest, uniqueReactionsOrig):

    error = False

    # check for unique reactions in one of the models:
    if uniqueReactionsOrig:
        error = True
        logging.error(
            'The original model has reactions that the tested model does not have: {}'
            .format(uniqueReactionsOrig)
            )

    if uniqueReactionsTest:
        error = True
        logging.error(
            'The tested model has reactions that the original model does not have: {}'
            .format(uniqueReactionsTest)
            )

    if commonReactions:
        for rxn1, rxn2 in commonReactions:
            logging.info('    {0!s}'.format(rxn1))
            if rxn1.kinetics and rxn2.kinetics:
                if not rxn1.kinetics.isIdenticalTo(rxn2.kinetics):
                    error = True

                    logging.error('Non-identical kinetics for tested and original reaction: {} \n {}'
                            .format(rxn1, rxn2))

                    logging.error('        {0:7.2f} {1:7.2f} {2:7.2f} {3:7.2f} {4:7.2f} {5:7.2f} {6:7.2f} {7:7.2f}'.format(
                        math.log10(rxn1.kinetics.getRateCoefficient(300, 1e5)),
                        math.log10(rxn1.kinetics.getRateCoefficient(400, 1e5)),
                        math.log10(rxn1.kinetics.getRateCoefficient(500, 1e5)),
                        math.log10(rxn1.kinetics.getRateCoefficient(600, 1e5)),
                        math.log10(rxn1.kinetics.getRateCoefficient(800, 1e5)),
                        math.log10(rxn1.kinetics.getRateCoefficient(1000, 1e5)),
                        math.log10(rxn1.kinetics.getRateCoefficient(1500, 1e5)),
                        math.log10(rxn1.kinetics.getRateCoefficient(2000, 1e5)),
                    ))

                    logging.error('        {0:7.2f} {1:7.2f} {2:7.2f} {3:7.2f} {4:7.2f} {5:7.2f} {6:7.2f} {7:7.2f}'.format(
                        math.log10(rxn2.kinetics.getRateCoefficient(300, 1e5)),
                        math.log10(rxn2.kinetics.getRateCoefficient(400, 1e5)),
                        math.log10(rxn2.kinetics.getRateCoefficient(500, 1e5)),
                        math.log10(rxn2.kinetics.getRateCoefficient(600, 1e5)),
                        math.log10(rxn2.kinetics.getRateCoefficient(800, 1e5)),
                        math.log10(rxn2.kinetics.getRateCoefficient(1000, 1e5)),
                        math.log10(rxn2.kinetics.getRateCoefficient(1500, 1e5)),
                        math.log10(rxn2.kinetics.getRateCoefficient(2000, 1e5)),
                    ))
    return error


if __name__ == '__main__':
    main()