.PHONY: test test-all test-positive-case test-negative-case

# Main test target to run all tests
test: test-all

# Run all test cases
test-all: test-positive-case test-negative-case
	@echo "\n✅ All tests completed successfully"

# Test positive case - expects status code 200 and address in response
test-positive-case:
	@echo "\n🧪 Testing positive case (address found)..."
	@sam local invoke IgPostExtractor --event tests/events/positive_case.json | tail -n 1 | \
	jq -e '(.statusCode == 200)' > /dev/null && \
	echo "✅ Test passed: Status code is 200 and contains address" || \
	(echo "❌ Test failed: Response doesn't meet expectations"; exit 1)

# Test negative case - expects status code 400
test-negative-case:
	@echo "\n🧪 Testing negative case (no address found)..."
	@sam local invoke IgPostExtractor --event tests/events/negative_case.json | tail -n 1 | \
	jq -e '.statusCode == 400' > /dev/null && \
	echo "✅ Test passed: Status code is 400" || \
	(echo "❌ Test failed: Status code is not 400"; exit 1)
