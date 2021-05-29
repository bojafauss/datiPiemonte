#!/bin/bash

R -q -e "devtools::document('datiPiemonte')"
R -q -e "devtools::build('datiPiemonte')"
R -q -e "devtools::test('datiPiemonte')"

R CMD build datiPiemonte
R CMD check datiPiemonte_*.tar.gz
