all: team

compiler: 
	mkdir -p generated
	mkdir -p build
	mkdir -p outputs
	flex -o generated/scanner.cpp src/scanner.ll
	bison -d -o generated/parser.cpp src/parser.yy
	g++ -std=c++0x -c -o build/parser.o generated/parser.cpp -g
	g++ -std=c++0x -c -o build/scanner.o generated/scanner.cpp -g
	g++ -std=c++0x -c -o build/main.o src/main.cpp -g
	g++ -std=c++0x -c -o build/AST.o src/AST.cpp -g
	g++ -std=c++0x -o Micro build/scanner.o build/AST.o build/parser.o build/main.o  -g 

clean:
	rm -rf generated
	rm -rf build
	rm -rf outputs
	rm -f Micro

run:
	./runme step7_in_out/inputs/step7_test1.micro outputs/out1.out
	./runme step7_in_out/inputs/step7_test2.micro outputs/out2.out
	./runme step7_in_out/inputs/step7_test3.micro outputs/out3.out
	./runme step7_in_out/inputs/step7_test4.micro outputs/out4.out
	./runme step7_in_out/inputs/step7_test5.micro outputs/out5.out
	./runme step7_in_out/inputs/step7_test6.micro outputs/out6.out
	./runme step7_in_out/inputs/step7_test7.micro outputs/out7.out  
	./runme step7_in_out/inputs/step7_test8.micro outputs/out8.out
	./runme step7_in_out/inputs/step7_test9.micro outputs/out9.out
	./runme step7_in_out/inputs/step7_test10.micro outputs/out10.out
	./runme step7_in_out/inputs/step7_test11.micro outputs/out11.out
	./runme step7_in_out/inputs/step7_test12.micro outputs/out12.out
	./runme step7_in_out/inputs/step7_test13.micro outputs/out13.out
	./runme step7_in_out/inputs/step7_test14.micro outputs/out14.out
	./runme step7_in_out/inputs/step7_test15.micro outputs/out15.out
	./runme step7_in_out/inputs/step7_test16.micro outputs/out16.out
	./runme step7_in_out/inputs/step7_test17.micro outputs/out17.out
	./runme step7_in_out/inputs/step7_test18.micro outputs/out18.out
	./runme step7_in_out/inputs/step7_test19.micro outputs/out19.out
	./runme step7_in_out/inputs/step7_test20.micro outputs/out20.out
	./runme step7_in_out/inputs/step7_test21.micro outputs/out21.out
	
diff:
	./tiny outputs/out1.out < step7_in_out/inputs/step7_test1.input
	./tiny outputs/out2.out< step7_in_out/inputs/step7_test2.input
	./tiny outputs/out3.out< step7_in_out/inputs/step7_test3.input
	./tiny outputs/out4.out< step7_in_out/inputs/step7_test4.input
	./tiny outputs/out5.out< step7_in_out/inputs/step7_test5.input
	./tiny outputs/out6.out< step7_in_out/inputs/step7_test6.input
	./tiny outputs/out7.out< step7_in_out/inputs/step7_test7.input
	./tiny outputs/out8.out< step7_in_out/inputs/step7_test8.input
	./tiny outputs/out9.out< step7_in_out/inputs/step7_test9.input
	./tiny outputs/out10.out< step7_in_out/inputs/step7_test10.input
	./tiny outputs/out11.out< step7_in_out/inputs/step7_test11.input
	./tiny outputs/out12.out< step7_in_out/inputs/step7_test12.input
	./tiny outputs/out13.out< step7_in_out/inputs/step7_test13.input
	./tiny outputs/out14.out< step7_in_out/inputs/step7_test14.input
	./tiny outputs/out15.out< step7_in_out/inputs/step7_test15.input
	./tiny outputs/out16.out< step7_in_out/inputs/step7_test16.input
	./tiny4 outputs/out17.out< step7_in_out/inputs/step7_test17.input
	./tiny outputs/out18.out< step7_in_out/inputs/step7_test18.input
	./tiny outputs/out19.out< step7_in_out/inputs/step7_test19.input
	./tiny outputs/out20.out< step7_in_out/inputs/step7_test20.input
	./tiny outputs/out21.out< step7_in_out/inputs/step7_test21.input

team: 	
	@echo "Team: TeamSS"
	@echo
	@echo Sahil Bhalla
	@echo bhallas
	@echo 
	@echo Akshay Raj
	@echo raj6

