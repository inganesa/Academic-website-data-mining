import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.util.List;
import java.util.regex.Pattern;

import edu.uci.ics.crawler4j.crawler.Page;
import edu.uci.ics.crawler4j.crawler.WebCrawler;
import edu.uci.ics.crawler4j.parser.HtmlParseData;
import edu.uci.ics.crawler4j.url.WebURL;

/**
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */





/**
 * @author Yasser Ganjisaffar <lastname at gmail dot com>
 */
public class myCrawler extends WebCrawler {

	public static String newline = System.getProperty("line.separator");
	private final static Pattern FILTERS = Pattern.compile(".*(\\.(css|js|bmp|gif|jpe?g" + "|png|tiff?|mid|mp2|mp3|mp4"
			+ "|wav|avi|mov|mpeg|ram|m4v|pdf" + "|rm|smil|wmv|swf|wma|zip|rar|gz|txt))$");

	/**
	 * You should implement this function to specify whether the given url
	 * should be crawled or not (based on your crawling logic).
	 */
	public boolean shouldVisit(WebURL url) {
		String href = url.getURL().toLowerCase();
		return !FILTERS.matcher(href).matches() && href.startsWith("http://www.colorado.edu/cs/") && !href.contains("calendar"); 
	}

	/**
	 * This function is called when a page is fetched and ready to be processed
	 * by your program.
	 */
	public void visit(Page page) {
		int docid = page.getWebURL().getDocid();
		String url = page.getWebURL().getURL();
		String domain = page.getWebURL().getDomain();
		String path = page.getWebURL().getPath();
		String subDomain = page.getWebURL().getSubDomain();
		String parentUrl = page.getWebURL().getParentUrl();

		String content1 =  Integer.toString(docid) + newline + url + newline + domain  + newline + path  + newline + subDomain + newline + parentUrl;
		String filePath1 = "C:\\Users\\Anitha\\Documents\\2nd sem\\DataMining\\project\\Data\\data1\\" + Integer.toString(docid) + ".txt";
		writeFile(content1, filePath1);

		if (page.getParseData() instanceof HtmlParseData) {
			HtmlParseData htmlParseData = (HtmlParseData) page.getParseData();
			String text = htmlParseData.getText();
			String html = htmlParseData.getHtml();
			List<WebURL> links = htmlParseData.getOutgoingUrls();
			String urlData = "";
			for(WebURL item : links)
			{
				urlData = urlData + newline + item;
			}
			String filepath2 = "C:\\Users\\Anitha\\Documents\\2nd sem\\DataMining\\project\\Data\\data2\\" + Integer.toString(docid)+ ".txt";
			String filepath3 = "C:\\Users\\Anitha\\Documents\\2nd sem\\DataMining\\project\\Data\\data3\\" + Integer.toString(docid)+ ".txt";
			String filepath4 = "C:\\Users\\Anitha\\Documents\\2nd sem\\DataMining\\project\\Data\\data4\\" + Integer.toString(docid)+ ".txt";
			writeFile(text, filepath2);
			writeFile(html, filepath3);
			writeFile(urlData, filepath4);

		}


	}

	//This function writes contents into the text file specified...
	private void writeFile(String contents, String fileName){
		Writer writer = null;
		try {
			File file = new File(fileName);
			writer = new BufferedWriter(new FileWriter(file));
			writer.append(contents);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				if (writer != null) {
					writer.close();
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		System.out.println("=============");
	}
}
