function randomSeed = loadRandomSeed(number)
filename = ['../include/randomSeed/randomSeed' num2str(number) '.mat'];
load(filename);
end