package customanalyser;

import java.io.IOException;
import java.util.List;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.lucene.analysis.Analyzer;
import org.apache.mahout.cf.taste.common.TasteException;
import org.apache.mahout.common.HadoopUtil;
import org.apache.mahout.common.Pair;
import org.apache.mahout.vectorizer.DictionaryVectorizer;
import org.apache.mahout.vectorizer.DocumentProcessor;
import org.apache.mahout.vectorizer.tfidf.TFIDFConverter;

public class Main {
	public static void main(String[] args) throws IOException, InterruptedException, ClassNotFoundException {
		// TODO Auto-generated method stub

		int minSupport = 5;
		int minDf = 20;
		int maxDFPercent = 80;
		int maxNGramSize = 1;
		int minLLRValue = 50;
		int reduceTasks = 1;
		int chunkSize = 200;
		int norm = 2;
		boolean sequentialAccessOutput = true;
		String outputDir = "/home/vmplanet/dm/CUEng/token";
		String inputDir = "/home/vmplanet/dm/CUEng/reuters-out-seqdir";
		String folderName = "tf";
		Configuration conf = new Configuration();
		
		HadoopUtil.delete(conf, new Path(outputDir));
		Path oPath = new Path(outputDir,
				DocumentProcessor.TOKENIZED_DOCUMENT_OUTPUT_FOLDER);
		/*Path iPath = new Path(inputDir,
				DocumentProcessor.TOKENIZED_DOCUMENT_OUTPUT_FOLDER);*/
		Pair<Long[],List<Path>> pair;
		
		myanalyzer analyzer = new myanalyzer();
		
		DocumentProcessor.tokenizeDocuments(
				new Path(inputDir), analyzer.getClass()
				.asSubclass(Analyzer.class), oPath, conf);
		
		analyzer.close();
		
		/*DictionaryVectorizer.createTermFrequencyVectors(tokenizedPath,new Path(outputDir), 
				conf, minSupport, maxNGramSize,minLLRValue, 2, true, reduceTasks,chunkSize, 
				sequentialAccessOutput, false);*/
		DictionaryVectorizer.createTermFrequencyVectors(oPath, new Path(outputDir), folderName, conf,minSupport,
				maxNGramSize,minLLRValue, -1,true, reduceTasks,chunkSize, sequentialAccessOutput,true);
		
		pair = TFIDFConverter.calculateDF(oPath,new Path(outputDir),conf,chunkSize);
        
		/*TFIDFConverter.processTfIdf(
				new Path(iPath,oPath, conf, pair,	
						minDf, maxDFPercent, norm, true, sequentialAccessOutput,
						false, reduceTasks);*/
				
		TFIDFConverter.processTfIdf(new Path(outputDir,
				DictionaryVectorizer.DOCUMENT_VECTOR_OUTPUT_FOLDER),
				new Path(outputDir), conf, pair,
				minDf, maxDFPercent, norm, true, sequentialAccessOutput,
				false, reduceTasks);
	}
}
