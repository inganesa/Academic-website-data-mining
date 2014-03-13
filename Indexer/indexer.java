/*
 * Indexer.java
 *
 * Created on 6 March 2006, 13:05
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */


import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
//import java.io.StringReader;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.Document;

import org.apache.lucene.analysis.Analyzer;

//import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.index.FieldInfo.IndexOptions;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
//import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.RAMDirectory;
import org.apache.lucene.util.Version;
import org.jsoup.Jsoup;
import org.apache.lucene.document.FieldType;

/**
 *
 * @author John
 */


public class indexer {
    
    /** Creates a new instance of Indexer */
    public indexer() {
    }
 
    private IndexWriter indexWriter = null;
    
    
    public IndexWriter getIndexWriter(boolean create) throws IOException {
        if (indexWriter == null) {
        	
            // To store an index on disk, use this instead:
        	 Directory directory = new RAMDirectory();
        	 Analyzer analyzer = new StandardAnalyzer(Version.LUCENE_42);
        	 IndexWriterConfig config = new IndexWriterConfig(Version.LUCENE_42, analyzer);
            //IndexWriter iwriter = new IndexWriter();
        	indexWriter = new IndexWriter(directory, config);
        }
        return indexWriter;
   }    
   
    public void closeIndexWriter() throws IOException {
        if (indexWriter != null) {
            indexWriter.close();
        }
   }
    
    private String readTitle (String file) throws IOException{
    	String data = readFile(file);
    	org.jsoup.nodes.Document doc = Jsoup.parse(data);
    	String title = doc.title();  
    	return title;
    }
    
    private String readFile( String file ) throws IOException {
    	BufferedReader br = new BufferedReader(new FileReader(file));
    	String everything;
        try {
            StringBuilder sb = new StringBuilder();
            String line = br.readLine();

            while (line != null) {
                sb.append(line);
               // sb.append("\n");
                line = br.readLine();
            }
            everything = sb.toString();           
          
        } finally {
            br.close();
        }
        return everything;
    }
    
    public void indexAcademics(String file1 , String file2) throws IOException {
        String contents = readFile(file1);
    	String title = readTitle(file2);
        System.out.println("Indexing CUCS: " + file1 + "\n" +  file2);
        
        IndexWriter writer = getIndexWriter(false);
        Document doc = new Document();
        FieldType fieldType = new FieldType();
        fieldType.setStoreTermVectors(true);
        fieldType.setStoreTermVectorPositions(true);
        fieldType.setIndexed(true);
        fieldType.setIndexOptions(IndexOptions.DOCS_AND_FREQS);
        fieldType.setStored(true);
        
        doc.add(new Field("title", title, fieldType));
       
        FieldType fieldType2 = new FieldType();
        fieldType2.setStoreTermVectors(true);
        fieldType2.setStoreTermVectorPositions(true);
        fieldType2.setIndexed(true);
        fieldType2.setIndexOptions(IndexOptions.DOCS_AND_FREQS);
        fieldType2.setStored(true);
        doc.add(new Field("content", contents, fieldType));
        
       
        writer.addDocument(doc);
    }   
    
    public void rebuildIndexes() throws IOException {
          //
          // Erase existing index
          //
          getIndexWriter(true);
          //
          // Index all Accommodation entries
          String folderPath1 = "C:\\Users\\Ramya\\Documents\\StudyWork\\Data Mining\\ProjectWork\\DataCUEnglish\\Data2\\";
          String folderPath2 = "C:\\Users\\Ramya\\Documents\\StudyWork\\Data Mining\\ProjectWork\\DataCUEnglish\\Data3\\";
          final File folder1 = new File(folderPath1);
          final File folder2 = new File(folderPath2);
          final File[] fileEntry1 = folder1.listFiles();
          final File[] fileEntry2 = folder2.listFiles();
        	 int len =   fileEntry1.length;
        	 for(int i = 0; i  < len ; i++)
        	 {	   
        	            String fileName1 = fileEntry1[i].getName();
        	    	    String fileName2  = fileEntry2[i].getName();
        	            String filePath1 = folderPath1 + fileName1;
        	            String filePath2 = folderPath2 + fileName2;
        	            indexAcademics(filePath1,filePath2);
        	        }
        	  
        	
          //
          // Don't forget to close the index writer when done
          //a
          closeIndexWriter();
     }    
    
  
    
    
}
