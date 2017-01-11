
echo "Benchmark vs. Testing Version Summary"

echo "========================================="
echo -e "${GREEN}benchmark version of RMG${NC}: "$RMG_BENCHMARK
cd $RMG_BENCHMARK
git log --format=%H%n%cd -1
echo ""

echo -e "${RED}testing version of RMG${NC}: "$RMG_TESTING  
cd $RMG_TESTING
git log --format=%H%n%cd -1
echo ""

echo -e "${GREEN}benchmark version of RMG-database${NC}: "$RMGDB_BENCHMARK
cd $RMGDB_BENCHMARK
git log --format=%H%n%cd -1
echo ""

echo -e "${RED}testing version of RMG-database${NC}: "$RMGDB_TESTING
cd $RMGDB_TESTING
git log --format=%H%n%cd -1
echo "========================================="

cd $TRAVIS_BUILD_DIR