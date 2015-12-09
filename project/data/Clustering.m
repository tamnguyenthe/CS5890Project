function [clusterMap,words,wordMap,V] = Clustering(k)
    [words,wordMap,V] = readBinVecFile('vectors.bin','vocab.txt');
    [IDX,C,~,D] = kmeans(V,k);
    
    clusterMap = containers.Map(words,IDX);
    
    for i=1:k
        index = 1:length(IDX);
        index = index(IDX==i);
        d = D(IDX==i,i);
        [d,sorted] = sort(d,'ascend');
        index = index(sorted);
        
        fid = fopen(['Cluster',num2str(i),'_',num2str(k),'.txt'],'w');
        for wi=1:length(index)
            fprintf(fid,'%s %f \n',words{index(wi)},d(wi));
        end
        fclose(fid);
    end
end

function [words,wordMap,W] = readBinVecFile(vectors_file,vocab_file)
    fid = fopen(vocab_file, 'r');
    words = textscan(fid, '%s %f');
    fclose(fid);
    words = words{1};
    vocab_size = length(words);
    wordMap = containers.Map(words(1:vocab_size),1:vocab_size);

    fid = fopen(vectors_file,'r');
    fseek(fid,0,'eof');
    vector_size = ftell(fid)/16/vocab_size - 1;
    frewind(fid);
    WW = fread(fid, [vector_size+1 2*vocab_size], 'double')'; 
    fclose(fid); 

    W1 = WW(1:vocab_size, 1:vector_size); % word vectors
    W2 = WW(vocab_size+1:end, 1:vector_size); % context (tilde) word vectors

    W = W1 + W2; %Evaluate on sum of word vectors
    W = bsxfun(@rdivide,W,sqrt(sum(W.*W,2))); %normalize vectors before evaluation
end