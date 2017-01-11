
echo "Benchmark vs. Testing Version Summary"

echo "========================================="
echo "benchmark version of RMG: "$RMG_BENCHMARK
cd $RMG_BENCHMARK
git log --format=%H%n%cd -1
echo ""

echo "testing version of RMG: "$RMG_TESTING  
cd $RMG_TESTING
git log --format=%H%n%cd -1
echo ""

echo "benchmark version of RMG-database: "$RMGDB_BENCHMARK
cd $RMGDB_BENCHMARK
git log --format=%H%n%cd -1
echo ""

echo "testing version of RMG-database: "$RMGDB_TESTING
cd $RMGDB_TESTING
git log --format=%H%n%cd -1
echo "========================================="

cd $TRAVIS_BUILD_DIR