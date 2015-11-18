package usu.useal;

import com.google.common.collect.BiMap;
import com.google.common.collect.HashBiMap;
import com.google.common.math.DoubleMath;
import com.opencsv.CSVReader;
import org.apache.commons.lang3.tuple.Pair;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import java.io.FileReader;
import java.io.IOException;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by tamnguyen on 11/17/15.
 */
public class TextAnalyzer {
    private Set<String> stopWords;
    private JSONArray trainJson;
    private JSONArray testJson;
    private List<Pair<String, Boolean>> textTrain;


    public TextAnalyzer(String trainFileName, String testFileName) {
        JSONParser parser = new JSONParser();
        try {
            Object obj = parser.parse(new FileReader(trainFileName));
            trainJson = (JSONArray)obj;
            obj = parser.parse(new FileReader(testFileName));
            testJson = (JSONArray)obj;
            System.out.println(trainJson.get(2));
        } catch (IOException e) {
            e.printStackTrace();
        } catch (ParseException e) {
            e.printStackTrace();
        }
        textTrain = new ArrayList<Pair<String, Boolean>>();
        Iterator iterator = trainJson.iterator();
        while (iterator.hasNext()) {
            JSONObject jsonObject = (JSONObject) iterator.next();
            String requestTitle = (String) jsonObject.get("request_title");
            requestTitle = requestTitle.toLowerCase();
            requestTitle = requestTitle.replace("request", "");
            String requestTextEditAware = (String) jsonObject.get("request_text_edit_aware");
            requestTextEditAware = requestTextEditAware.toLowerCase();
            String combinedText = requestTitle + ". " + requestTextEditAware;
            Boolean requesterReceivedPizza = (Boolean) jsonObject.get("requester_received_pizza");
            textTrain.add(Pair.of(combinedText, requesterReceivedPizza));
        }
        System.out.println(textTrain.get(2));
    }

    public void loadStopWords(String fileName) {
        stopWords = new HashSet<String>();
        try {
            CSVReader csvReader = new CSVReader(new FileReader(fileName));
            String[] nextLine;
            while ((nextLine = csvReader.readNext()) != null) {
                stopWords.add(nextLine[0]);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private List<Pair<List<String>, Boolean>> tokenizedTextTrain;
    private BiMap<String, Integer> dictionary;
    private List<Pair<Map<String, Integer>, Boolean>> tf;
    private Map<String, Integer> dfFalse;
    private Map<String, Integer> dfTrue;
    private Map<String, Integer> df;

    public void tokenize() {
        tokenizedTextTrain = new ArrayList<Pair<List<String>, Boolean>>();
        dictionary = HashBiMap.create();
        tf = new ArrayList<Pair<Map<String, Integer>, Boolean>>();
        dfFalse = new HashMap<String, Integer>();
        dfTrue = new HashMap<String, Integer>();
        df = new HashMap<String, Integer>();

        Pattern pattern = Pattern.compile("([a-z][a-z'\\-_]+[a-z])|([a-z]+)");
        for (Pair<String, Boolean> request : textTrain) {
            Map<String, Integer> docTf = new HashMap<String, Integer>();
            Matcher matcher = pattern.matcher(request.getLeft());
            List<String> wordList = new ArrayList<String>();
            while (matcher.find()) {
                String word = matcher.group();
                if (!stopWords.contains(word)) {
                    wordList.add(word);
                    if (!dictionary.containsKey(word)) dictionary.put(word, dictionary.size());
                    Integer count = docTf.get(word);
                    if (count == null) docTf.put(word, 1);
                    else docTf.put(word, count+1);
                }
            }
            tf.add(Pair.of(docTf, request.getRight()));
            tokenizedTextTrain.add(Pair.of(wordList, request.getRight()));
        }
        for (Pair<Map<String, Integer>, Boolean> request : tf) {
            for (Map.Entry<String, Integer> term : request.getLeft().entrySet()) {
                Integer integer = df.get(term.getKey());
                if (integer == null) df.put(term.getKey(), 1);
                else df.put(term.getKey(), integer+1);
                if (request.getRight().equals(Boolean.FALSE)) {
                    Integer count = dfFalse.get(term.getKey());
                    if (count == null) dfFalse.put(term.getKey(), 1);
                    else dfFalse.put(term.getKey(), count+1);
                } else {
                    Integer count = dfTrue.get(term.getKey());
                    if (count == null) dfTrue.put(term.getKey(), 1);
                    else dfTrue.put(term.getKey(), count+1);
                }
            }
        }
        System.out.println(tokenizedTextTrain.get(2));
        System.out.println(tf.get(2));
        System.out.println(df.size());
        System.out.println(dfFalse.size());
        System.out.println(dfTrue.size());
        System.out.println(dictionary.size());
    }

    public void rankWord() {
        List<Pair<String, Double>> falseRanking = new ArrayList<Pair<String, Double>>();
        List<Pair<String, Double>> trueRanking = new ArrayList<Pair<String, Double>>();
        for (Map.Entry<String, Integer> falseEntry : dfFalse.entrySet()) {
            double n = (double)falseEntry.getValue();
            double p;
            if (dfTrue.containsKey(falseEntry.getKey())) p = dfTrue.get(falseEntry.getKey());
            else p = 0.1;
            double ranking = (n/p)*(n-p);
            falseRanking.add(Pair.of(falseEntry.getKey(),ranking ));
        }
        for (Map.Entry<String, Integer> trueEntry : dfTrue.entrySet()) {
            double n = (double)trueEntry.getValue();
            double p;
            if (dfFalse.containsKey(trueEntry.getKey())) p = dfFalse.get(trueEntry.getKey());
            else p = 0.1;
            double ranking = (n/p)*(n-p);
            trueRanking.add(Pair.of(trueEntry.getKey(),ranking ));
        }

        Collections.sort(falseRanking, new Comparator<Pair<String, Double>>() {
            @Override
            public int compare(Pair<String, Double> o1, Pair<String, Double> o2) {
                return - Double.compare(o1.getRight(), o2.getRight());
            }
        });

        Collections.sort(trueRanking, new Comparator<Pair<String, Double>>() {
            @Override
            public int compare(Pair<String, Double> o1, Pair<String, Double> o2) {
                return - Double.compare(o1.getRight(), o2.getRight());
            }
        });

        System.out.println(falseRanking.subList(0, 30));
        System.out.println(trueRanking.subList(0, 30));
    }


}
