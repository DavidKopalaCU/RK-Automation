//
//  main.cpp
//  GDSLayoutParser
//
//  Created by David Kopala on 1/12/18.
//  Copyright © 2018 Red Wave. All rights reserved.
//

#include <iostream>
#include <fstream>
#include <vector>
#include <math.h>
#include <algorithm>

using namespace std;

#define XALIGN      98
#define YALIGN      99

struct box {
    int x0 = -1;
    int y0 = -1;
    int xf = -1;
    int yf = -1;
    string line;
};

struct center {
    float x = 0;
    float y = 0;
};

int indexOf(string *line, char c) {
    for (int i = 0; i < line->length(); i++) {
        char t = line->at(i);
        if (t == c) {
            return i;
        }
    }
    return -1;
}

box createBoxFromLine(string *line) {
    box b;
    b.line = *line;
    
    int len = indexOf(line, ')') - indexOf(line, '(');
    string coords = line->substr(indexOf(line, '(')+1, len-1);
    
    string temp = "";
    int index = 0;
    //Get x0
    while (coords[index] != ',') {
        temp += coords[index];
        index++;
    }
    b.x0 = atoi(temp.c_str());
    temp = "";
    index++;
    
    //Get y0
    while (coords[index] != ';') {
        temp += coords[index];
        index++;
    }
    b.yf = atoi(temp.c_str());
    temp = "";
    index++;
    
    //Get xf
    while (coords[index] != ',') {
        temp += coords[index];
        index++;
    }
    b.xf = atoi(temp.c_str());
    temp = "";
    index++;
    
    //Get yf
    while (index < line->length()) {
        temp += coords[index];
        index++;
    }
    b.y0 = atoi(temp.c_str());
    temp = "";
    
    return b;
}

//Returns which axis the boxes are aligned on
int isAligned(box a, box b) {
    if ((a.x0 == b.x0) || (a.xf == b.xf)) {
        return YALIGN;
    } else if ((a.y0 == b.y0) || (a.yf == b.yf)){
        return XALIGN;
    } else {
        return -1;
    }
}

int distance(box a, box b, int alignmentType) {
    if (alignmentType == XALIGN) {
        return b.x0 - a.xf;
    } else if (alignmentType == YALIGN) {
        return b.y0 - a.yf;
    } else {
        return -1;
    }
}

bool contains(vector<string> *vec, string *line) {
    for (int i = 0; i < vec->capacity(); i++) {
        if (vec->operator[](i) == *line) {
            return true;
        }
    }
    return false;
}

int main(int argc, const char * argv[]) {
    
    string filepath;
    string outFilepath;
    if (argc != 3) {
        filepath = "/Users/davidkopala/Downloads/box_stuff_2.csv";
        outFilepath = "/Users/davidkopala/Downloads/box_stuff_2_PARSED.csv";
        cout<<"Usage: GDSLayoutParser.exe <input file> <output file>"<<endl;
        cout<<"Using defaults."<<endl;
    } else {
        filepath = argv[1];
        outFilepath = argv[2];
    }
    cout<<"Input: "<<filepath<<endl;
    cout<<"Output: "<<""<<endl;
    
    int foundCount = 0;
    
    vector<string> foundBoxes;
    vector<center> centers;
    ifstream file = ifstream(filepath);
    string line;
    getline(file, line);    //SKIPS THE FIRST LINE
    while (!file.eof()) {
        getline(file, line);
        
        if (line.length() == 0) {
            continue;
        }
        if (contains(&foundBoxes, &line)) {
            continue;
        }
        
        box b = createBoxFromLine(&line);
        
        int minUp = 99999;
        box minUpB;
        int minDown = 99999;
        box minDownB;
        int minLeft = 99999;
        box minLeftB;
        int minRight = 99999;
        box minRightB;
        
        //Find adjecent boxes
        ifstream nestedFile = ifstream(filepath);
        string nestedLine;
        getline(nestedFile, nestedLine);
        while (!nestedFile.eof()) {
            getline(nestedFile, nestedLine);
            
            if (nestedLine.length() == 0) {
                continue;
            }
            if (contains(&foundBoxes, &nestedLine)) {
                continue;
            }
            
            box nb = createBoxFromLine(&nestedLine);
            if (b.line == nb.line) {
                continue;
            }
            
            int alignType = isAligned(b, nb);
            if (alignType == -1) {
                continue;
            }
            int dist = distance(b, nb, alignType);
            if ((dist == 50) || (dist == -50)) {    //PREVENT PADS THAT ARE VERY CLOSE TO EACH OTHER FROM BEING GROUPED
                continue;
            }
            if (dist < 0) {
                dist = abs(dist);
                if (alignType == XALIGN) {
                    if (dist < minLeft) {
                        minLeft = dist;
                        minLeftB = nb;
                    }
                } else {
                    if (dist < minDown) {
                        minDown = dist;
                        minDownB = nb;
                    }
                }
            } else {
                if (alignType == XALIGN) {
                    if (dist < minRight) {
                        minRight = dist;
                        minRightB = nb;
                    }
                } else if (alignType == YALIGN) {
                    if (dist < minUp) {
                        minUp = dist;
                        minUpB = nb;
                    }
                }
            }
        }
        
        box ul; ul.x0 = minLeftB.x0; ul.y0 = minUpB.y0;
        box ur; ur.xf = minRightB.xf; ur.y0 = minUpB.y0;
        box ll; ll.x0 = minLeftB.x0; ll.yf = minDownB.yf;
        box lr; lr.xf = minRightB.xf; lr.yf = minDownB.yf;
        
        box adj;
        ifstream adjFile = ifstream(filepath);
        string adjLine;
        getline(adjFile, adjLine);
        while(!adjFile.eof()) {
            getline(adjFile, adjLine);
            if (adjLine.length() == 0) {
                continue;
            }
            
            box adjBox = createBoxFromLine(&adjLine);
            center c;
            if ((adjBox.x0 == ul.x0) && (adjBox.y0 == ul.y0)) {             //ADJACENT BOX IS UPPER LEFT
                adj = adjBox;
                c.x = (adj.x0 + b.xf) / 2.0;
                c.y = (adj.y0 + b.yf) / 2.0;
                centers.push_back(c);
                foundBoxes.push_back(minUpB.line);
                foundBoxes.push_back(minLeftB.line);
                break;
            } else if ((adjBox.xf == ur.xf) && (adjBox.y0 == ur.y0)) {      //ADJECNT BOX IS UPPER RIGHT
                adj = adjBox;
                c.x = (adj.xf + b.x0) / 2.0;
                c.y = (adj.y0 + b.yf) / 2.0;
                centers.push_back(c);
                foundBoxes.push_back(minUpB.line);
                foundBoxes.push_back(minRightB.line);
                break;
            } else if ((adjBox.x0 == ll.x0) && (adjBox.yf == ll.yf)) {      //ADJACENT BOX IS LOWER LEFT
                adj = adjBox;
                c.x = (adj.xf + b.x0) / 2.0;
                c.y = (adj.yf + b.y0) / 2.0;
                centers.push_back(c);
                foundBoxes.push_back(minDownB.line);
                foundBoxes.push_back(minLeftB.line);
                break;
            } else if ((adjBox.xf == lr.xf) && (adjBox.yf == lr.xf)) {      //ADJACENT BOX IS LOWER RIGHT
                adj = adjBox;
                c.x = (adj.xf + b.x0) / 2.0;
                c.y = (adj.yf + b.yf) / 2.0;
                centers.push_back(c);
                foundBoxes.push_back(minDownB.line);
                foundBoxes.push_back(minRightB.line);
                break;
            }
        }
        
        if (adj.x0 == -1) {
            //cout<<"NO SET"<<endl;
            continue;
        }
        
        foundBoxes.push_back(b.line);
        foundBoxes.push_back(adj.line);
        foundCount++;
    }
    cout<<"Found "<<foundCount<<" sets."<<endl;
    
    center sorted[centers.capacity()];
    sorted[0] = centers.back(); centers.pop_back();
    int sortedIndex = 1;
    while (centers.size() != 0) {
        center last = sorted[sortedIndex-1];
        float minDist = 99999;
        int minIndex;
        for (int i = 0; i < centers.size(); i++) {
            center c = centers.at(i);
            float distance = sqrt(pow((last.x - c.x), 2) + pow(last.y - c.y, 2));
            if (distance < minDist) {
                minDist = distance;
                minIndex = i;
            }
        }
        sorted[sortedIndex++] = centers.at(minIndex);
        centers.erase(centers.begin()+(minIndex));
    }
    
    ofstream outFile = ofstream(outFilepath);
    for (int i = 0; i < foundCount; i++) {
        outFile<<sorted[i].x<<","<<sorted[i].y<<endl;
    }
    outFile.close();
    
    return 0;
}
