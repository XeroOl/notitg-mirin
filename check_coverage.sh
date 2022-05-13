if busted --coverage --suppress-pending;
then
    luacov
    awk 't&&(--l<0){print}/Summary/{t=1;l=1}/Total/{print "##[set-output name=coverage;]" int($NF)}' luacov.report.out
    rm luacov.report.out
fi
rm luacov.stats.out
