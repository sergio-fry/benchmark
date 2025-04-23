suite:
	make test
	make test

test:
	docker compose run --rm --remove-orphans -it -e VERBOSE=false -e FORMAT=json -e ACCURACITY=0.95 bench ruby benchmark.rb http://rails-mri:8080/json
	docker compose run --rm --remove-orphans -it -e VERBOSE=false -e FORMAT=json -e ACCURACITY=0.95 bench ruby benchmark.rb http://rails-truffle:8080/json
	docker compose run --rm --remove-orphans -it -e VERBOSE=false -e FORMAT=json -e ACCURACITY=0.95 bench ruby benchmark.rb http://rails-truffle-graalvm:8080/json
