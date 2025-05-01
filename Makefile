suite:
	make run-app
	sleep 15
	make mri_json
	make mri_json
	make mri_json
	make truffle_json
	make truffle_json
	make truffle_json
	make truffle_graalvm_json
	make truffle_graalvm_json
	make truffle_graalvm_json

mri_json:
	docker compose run --rm --remove-orphans -it -e VERBOSE=false -e FORMAT=json -e ACCURACITY=0.95 bench ruby benchmark.rb http://rails-mri:8080/json

truffle_json:
	docker compose run --rm --remove-orphans -it -e VERBOSE=false -e FORMAT=json -e ACCURACITY=0.95 bench ruby benchmark.rb http://rails-truffle:8080/json

truffle_graalvm_json:
	docker compose run --rm --remove-orphans -it -e VERBOSE=false -e FORMAT=json -e ACCURACITY=0.95 bench ruby benchmark.rb http://rails-truffle-graalvm:8080/json

mri_db:
	docker compose run --rm --remove-orphans -it -e VERBOSE=false -e FORMAT=json -e ACCURACITY=0.95 bench ruby benchmark.rb http://rails-mri:8080/db

run-app:
	docker compose up -d
