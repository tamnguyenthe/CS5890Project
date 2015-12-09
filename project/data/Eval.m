function [ ] = Eval( k )
    s = RandStream('mt19937ar','Seed',1);
    RandStream.setGlobalStream(s);

    [clusterMap,words,wordMap,V] = Clustering(k);
    [labels, texts] = ReadCSV('pizza.csv');
    
    vecs = calculateCluster(k,texts,clusterMap);
    
    SVMStruct = svmtrain(vecs,labels,'autoscale',false);
    
    featureWeights = SVMStruct.SupportVectors'*SVMStruct.Alpha;
    [~,index] = sort(abs(featureWeights),'descend');
    featureWeights = featureWeights(index);
    fid = fopen(['Cluster',num2str(k),'result.txt'],'w');
    for i=1:k
        fprintf(fid,'Cluster %d %f \n',index(i),featureWeights(i));
    end
    fclose(fid);
    
    score = [];
    label = [];
    measures = zeros(1,7);
    nFold = 10;
    indices = crossvalind('Kfold', labels, nFold);
    for i = 1:nFold
        test = (indices == i); train = ~test;
        SVMStruct = svmtrain(vecs(train,:),labels(train),'autoscale',false);
        testLables = svmclassify(SVMStruct,vecs(test,:));
        eval = Evaluate(labels(test),testLables);
        measures = measures+eval;
        
        f = getScore(SVMStruct,vecs(test,:));
        score = [score;f];
        label = [label;labels(test)];
    end
    measures = measures./nFold;
    
    [X,Y,~,AUC] = perfcurve(label,score,1);
    plot(X,Y);
    print(['Cluster',num2str(k),'ROC.pdf'],'-dpng')
    
    fid = fopen(['Cluster',num2str(k),'result.txt'],'a');
    fprintf(fid,'Cluster vec \n');
    fprintf(fid,'AUC %f\n',AUC);
    fprintf(fid,'%s %s %s %s %s %s %s \n','accuracy','sensitivity','specificity','precision','recall','f_measure','gmean');
    fprintf(fid,'%f %f %f %f %f %f %f \n',measures(1),measures(2),measures(3),measures(4),measures(5),measures(6),measures(7));
    fclose(fid);
    
    vecs = calculateVec(texts,wordMap,V);
    
    score = [];
    label = [];
    measures = zeros(1,7);
    nFold = 10;
    indices = crossvalind('Kfold', labels, nFold);
    for i = 1:nFold
        test = (indices == i); train = ~test;
        SVMStruct = svmtrain(vecs(train,:),labels(train),'autoscale',false);
        testLables = svmclassify(SVMStruct,vecs(test,:));
        eval = Evaluate(labels(test),testLables);
        measures = measures+eval;
        
        f = getScore(SVMStruct,vecs(test,:));
        score = [score;f];
        label = [label;labels(test)];
    end
    measures = measures./nFold;
    
    [X,Y,~,AUC] = perfcurve(label,score,1);
    plot(X,Y);
    print('Average_ROC.pdf','-dpng')
    
    fid = fopen(['Cluster',num2str(k),'result.txt'],'a');
    fprintf(fid,'Word2Vec average \n');
    fprintf(fid,'AUC %f\n',AUC);
    fprintf(fid,'%s %s %s %s %s %s %s \n','accuracy','sensitivity','specificity','precision','recall','f_measure','gmean');
    fprintf(fid,'%f %f %f %f %f %f %f \n',measures(1),measures(2),measures(3),measures(4),measures(5),measures(6),measures(7));
    fclose(fid);
end

function [vecs] = calculateCluster(k,texts,clusterMap)
    vecs = zeros(length(texts),k);
    for ri=1:length(texts)
        text = texts{ri};
        words = strsplit(text,' ');
        for wi=1:length(words)
            if(isKey(clusterMap,words{wi}))
                clusterI = clusterMap(words{wi});
                vecs(ri,clusterI) = vecs(ri,clusterI)+1;
            end
        end
        vecs(ri,:) = vecs(ri,:)./length(words);
    end
end

function [vecs] = calculateVec(texts,wordMap,V)
    vecs = zeros(size(V,1),size(V,2));
    for ri=1:length(texts)
        text = texts{ri};
        words = strsplit(text,' ');
        for wi=1:length(words)
            if(isKey(wordMap,words{wi}))
                vecI = wordMap(words{wi});
                vecs(ri,:) = vecs(ri,:)+V(vecI,:);
            end
        end
        vecs(ri,:) = vecs(ri,:)./length(words);
    end
end

function [labels, texts] = ReadCSV(fileName)
    fid = fopen(fileName,'r');
    CSV = textscan(fid, '%d%s%s', 4040, 'delimiter',',');
    fclose(fid);
    
    labels = strcmp(CSV{2},'true')+0;
    labels(labels==0) = -1;
    texts = CSV{3};
end

function split = strsplit(s,dl)
    split = regexp(strtrim(s),dl,'split');
end

function EVAL = Evaluate(ACTUAL,PREDICTED)
    % This fucntion evaluates the performance of a classification model by 
    % calculating the common performance measures: Accuracy, Sensitivity, 
    % Specificity, Precision, Recall, F-Measure, G-mean.
    % Input: ACTUAL = Column matrix with actual class labels of the training
    %                 examples
    %        PREDICTED = Column matrix with predicted class labels by the
    %                    classification model
    % Output: EVAL = Row matrix with all the performance measures


    idx = (ACTUAL()==1);

    p = length(ACTUAL(idx));
    n = length(ACTUAL(~idx));
    N = p+n;

    tp = sum(ACTUAL(idx)==PREDICTED(idx));
    tn = sum(ACTUAL(~idx)==PREDICTED(~idx));
    fp = n-tn;
    fn = p-tp;

    tp_rate = tp/p;
    tn_rate = tn/n;

    accuracy = (tp+tn)/N;
    sensitivity = tp_rate;
    specificity = tn_rate;
    precision = tp/(tp+fp);
    recall = sensitivity;
    f_measure = 2*((precision*recall)/(precision + recall));
    gmean = sqrt(tp_rate*tn_rate);

    EVAL = [accuracy sensitivity specificity precision recall f_measure gmean];
end

function [f] = getScore(svm,Xnew)
    sv = svm.SupportVectors;
    alphaHat = svm.Alpha;
    bias = svm.Bias;
    kfun = svm.KernelFunction;
    kfunargs = svm.KernelFunctionArgs;
    f = kfun(sv,Xnew,kfunargs{:})'*alphaHat(:) + bias;
    f = -f; % flip the sign to get the score for the +1 class
end