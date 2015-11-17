package usu.useal;

import com.opencsv.CSVReader;
import com.sun.tools.corba.se.idl.constExpr.BooleanAnd;
import com.sun.tools.javac.util.Pair;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import javax.print.DocFlavor;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

/**
 * Created by tamnguyen on 11/17/15.
 */
public class TextAnalyzer {
    private Set<String> stopWords;
    private JSONArray trainJson;
    private JSONArray testJson;
    private List<Pair<String, Boolean>> text;

    public TextAnalyzer(String trainFileName, String testFileName) {
        JSONParser parser = new JSONParser();
        try {
            Object obj = parser.parse(new FileReader(trainFileName));
            trainJson = (JSONArray)obj;
            obj = parser.parse(new FileReader(testFileName));
            testJson = (JSONArray)obj;
        } catch (IOException e) {
            e.printStackTrace();
        } catch (ParseException e) {
            e.printStackTrace();
        }
        Iterator iterator = trainJson.iterator();
        while (iterator.hasNext()) {
            JSONObject jsonObject = (JSONObject) iterator.next();
        }
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



}
