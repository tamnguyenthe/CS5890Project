package usu.useal;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Scanner;

/**
 * Created by tamnguyen on 12/8/15.
 */
public class WordcloudGenerator {

    public static void main(String[] args) throws FileNotFoundException {
        String rootDir = "/Users/tamnguyen/Documents/PycharmProjects/CS5890Project/data";
        Scanner scanner = new Scanner(new File(rootDir + File.separator + "Cluster18_20.txt"));
        PrintWriter printWriter = new PrintWriter(new File("Cluster18_20.txt"));
        String word;
        double weight;
        ArrayList<String> words = new ArrayList<String>();
        for (int i = 0; i < 40; i++) {
            word = scanner.next();
            weight = scanner.nextDouble();
            words.add(word);
        }

        for (int i = 0; i < words.size(); i++) {
//            for (int j = 0; j < words.size() - i; j++) {
                printWriter.println(words.get(i));
//            }
        }
        printWriter.close();
     }

}
