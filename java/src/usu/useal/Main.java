package usu.useal;

import java.io.File;

public class Main {

    public static void main(String[] args) {
        String rootDir = "/Users/tamnguyen/Documents/PycharmProjects/CS5890Project/data";
        TextAnalyzer textAnalyzer = new TextAnalyzer( rootDir + File.separator + "train.json", rootDir+ File.separator + "test.json");
        textAnalyzer.loadStopWords(rootDir + File.separator + "english.stop");
        textAnalyzer.tokenize();
        textAnalyzer.rankWord();
    }
}
