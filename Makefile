.PHONY: format lint test coverage clean

# run "make VERSION=x.y.z" to specify version
VERSION=git-$(shell git rev-parse --short HEAD)
FILENAME=mirin-template-$(VERSION)

$(FILENAME).zip: lint test
	mkdir -p build
	cp -r Song.ogg Song.sm lua template build
	sed 's/$$VERSION/'"$(VERSION)"'/' build/template/main.xml -i
	(cd build && zip ../"$(FILENAME)".zip . -r)
	rm build -rf

format:
	stylua template

lint:
	stylua -c template || (echo "If this fails, run 'make format' to reformat the code" && false)
	luacheck template

test:
	busted --suppress-pending
	stylua -c template
	luacheck template

coverage:
	busted --coverage --suppress-pending || true
	luacov
	awk 't&&(--l<0){print}/Summary/{t=1;l=1}' luacov.report.out
	awk '/Total/{print "##[set-output name=coverage;]" int($$NF)}' luacov.report.out >> $GITHUB_OUTPUT
	rm luacov.report.out
	rm luacov.stats.out

clean:
	# from the default target
	rm -rf build
	rm -rf $(FILENAME)
	# from coverage
	rm -rf luacov.report.out
	rm -rf luacov.stats.out
