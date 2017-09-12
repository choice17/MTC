function randomSeedGen(number,name)
for i = 5:number
    randomSeed = rng(randi(10000));
    rng(randomSeed);
    randn
    %randomSeed.State
    filename = [name num2str(i) '.mat'];
    save(filename,'randomSeed');    
end


