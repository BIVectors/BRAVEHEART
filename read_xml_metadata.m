%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% read_xml_metadata.m -- Read metadata from XML files into GUI
% Copyright 2016-2025 Hans F. Stabenau and Jonathan W. Waks
% 
% Source code/executables: https://github.com/BIVectors/BRAVEHEART
% Contact: braveheart.ecg@gmail.com
% 
% BRAVEHEART is free software: you can redistribute it and/or modify it under the terms of the GNU 
% General Public License as published by the Free Software Foundation, either version 3 of the License, 
% or (at your option) any later version.
%
% BRAVEHEART is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
% See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along with this program. 
% If not, see <https://www.gnu.org/licenses/>.
%
% This software is for research purposes only and is not intended to diagnose or treat any disease.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function M = read_xml_metadata(filename, ecg_string)

M = struct;

% Deal with parsing issues with xmlread
% Create Document Builder
builder = javax.xml.parsers.DocumentBuilderFactory.newInstance;

% Disable dtd validation
builder.setFeature('http://apache.org/xml/features/nonvalidating/load-external-dtd', false);

% Read the xml file
tree = xmlread(filename, builder);

% Get filename
[~,f,e] = fileparts(filename);
fname = strcat(f,e);

% Set up defauly output structure
M = struct;
    M.Filename = fname;
    M.Firstname = 'N/A';
    M.Lastname = 'N/A';
    M.PatientID = 'N/A';
    M.DOB = 'N/A';
    M.Age = 'N/A';
    M.Sex = 'N/A';
    M.Race = 'N/A';
    M.Date = 'N/A';
    M.Time = 'N/A';

% Java XML setup
import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;
        
% Switch for each of the 3 XMLs supported so far
switch ecg_string

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
case 'muse_xml'

    patient_demographics = tree.getElementsByTagName('PatientDemographics');

    % Name
    try
        M.Firstname = char(patient_demographics.item(0).getElementsByTagName('PatientLastName').item(0).getFirstChild.getNodeValue);
    catch ME
    end

    try
        M.Lastname = char(patient_demographics.item(0).getElementsByTagName('PatientFirstName').item(0).getFirstChild.getNodeValue);
    catch ME
    end

    % Patient ID
    try
        M.PatientID = char(patient_demographics.item(0).getElementsByTagName('PatientID').item(0).getFirstChild.getNodeValue);
    catch ME
    end

    % DOB
    try
        M.DOB = char(patient_demographics.item(0).getElementsByTagName('DateofBirth').item(0).getFirstChild.getNodeValue);
    catch ME  
    end

    % Age
    try
        M.Age =  str2num(patient_demographics.item(0).getElementsByTagName('PatientAge').item(0).getFirstChild.getNodeValue);
    catch ME
    end

    % Sex
    try
        M.Sex =  char(patient_demographics.item(0).getElementsByTagName('Gender').item(0).getFirstChild.getNodeValue);
    catch ME 
    end

    % Race
    try
        M.Race = char(patient_demographics.item(0).getElementsByTagName('Race').item(0).getFirstChild.getNodeValue);
    catch ME
    end

    test_demographics = tree.getElementsByTagName('TestDemographics');

    % ECG Date
    try
        M.Date = char(test_demographics.item(0).getElementsByTagName('AcquisitionDate').item(0).getFirstChild.getNodeValue);
    catch ME
    end

    % ECG Time
    try
        M.Time = char(test_demographics.item(0).getElementsByTagName('AcquisitionTime').item(0).getFirstChild.getNodeValue);
    catch ME
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
case 'cardiosoft_xml'

    try
        expression = xpath.compile('//Name/GivenName');
        nameNode = expression.evaluate(tree, XPathConstants.NODE);
        M.Firstname = char(nameNode.getTextContent);
    catch ME
        M.Firstname = 'N/A';
    end

    try
        expression = xpath.compile('//Name/FamilyName');
        nameNode = expression.evaluate(tree, XPathConstants.NODE);
        M.Lastname = char(nameNode.getTextContent);
    catch ME 
    end

    try
        expression = xpath.compile('//PatientInfo/PID');
        nameNode = expression.evaluate(tree, XPathConstants.NODE);
        M.PatientID = char(nameNode.getTextContent);
    catch ME
    end

    try
        expression = xpath.compile('//PatientInfo/BirthDateTime/Month');
        nameNode = expression.evaluate(tree, XPathConstants.NODE);
        Mo = char(nameNode.getTextContent);

        expression = xpath.compile('//PatientInfo/BirthDateTime/Day');
        nameNode = expression.evaluate(tree, XPathConstants.NODE);
        D = char(nameNode.getTextContent);
        
        expression = xpath.compile('//PatientInfo/BirthDateTime/Year');
        nameNode = expression.evaluate(tree, XPathConstants.NODE);
        Y = char(nameNode.getTextContent);

        M.DOB = strcat(Mo,'/',D,'/',Y);
    catch ME
    end

    try
        M.Age = char(tree.getElementsByTagName('Age').item(0).getFirstChild.getNodeValue);
    catch ME
    end

    try 
        M.Sex = char(tree.getElementsByTagName('Gender').item(0).getFirstChild.getNodeValue);
    catch ME
    end

    try
        expression = xpath.compile('//PatientInfo/Race');
        nameNode = expression.evaluate(tree, XPathConstants.NODE);
        M.Race = char(nameNode.getTextContent);
    catch ME
    end

    try
        expression = xpath.compile('//ObservationDateTime/Day');
        nameNode = expression.evaluate(tree, XPathConstants.NODE);
        D = char(nameNode.getTextContent);

        expression = xpath.compile('//ObservationDateTime/Month');
        nameNode = expression.evaluate(tree, XPathConstants.NODE);
        Mo = char(nameNode.getTextContent);

        expression = xpath.compile('//ObservationDateTime/Year');
        nameNode = expression.evaluate(tree, XPathConstants.NODE);
        Y = char(nameNode.getTextContent);

        M.Date = strcat(Mo,'/',D,'/',Y);
    catch ME
    end

    try
        expression = xpath.compile('//ObservationDateTime/Hour');
        nameNode = expression.evaluate(tree, XPathConstants.NODE);
        H = char(nameNode.getTextContent);

        expression = xpath.compile('//ObservationDateTime/Minute');
        nameNode = expression.evaluate(tree, XPathConstants.NODE);
        Min = char(nameNode.getTextContent);
        
        expression = xpath.compile('//ObservationDateTime/Second');
        nameNode = expression.evaluate(tree, XPathConstants.NODE);
        S = char(nameNode.getTextContent);

        M.Time = strcat(H,':',Min,':',S);
    catch ME
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
case 'philips_xml'

    try 
        patient_demographics = tree.getElementsByTagName('firstname');
        M.Firstname = char(patient_demographics.item(0).getFirstChild.getNodeValue);
    catch ME
    end

    try 
        patient_demographics = tree.getElementsByTagName('lastname');
        M.Lastname = char(patient_demographics.item(0).getFirstChild.getNodeValue);
    catch ME
    end

    try 
        patient_demographics = tree.getElementsByTagName('MRN');
        M.PatientID = char(patient_demographics.item(0).getFirstChild.getNodeValue);
    catch ME
        end

    try 
        patient_demographics = tree.getElementsByTagName('dateofbirth');
        M.DOB = char(patient_demographics.item(0).getFirstChild.getNodeValue);
    catch ME
    end

    try
        patient_demographics = tree.getElementsByTagName('age');
        M.Age =  str2num(patient_demographics.item(0).getElementsByTagName('years').item(0).getFirstChild.getNodeValue);
    catch ME
    end
     
    try 
        patient_demographics = tree.getElementsByTagName('sex');
        M.Sex = char(patient_demographics.item(0).getFirstChild.getNodeValue);
    catch ME
    end

    try 
        patient_demographics = tree.getElementsByTagName('race');
        M.Race = char(patient_demographics.item(0).getFirstChild.getNodeValue);
    catch ME
    end

    try 
        patient_demographics = tree.getElementsByTagName('dataacquisition');
        
        k = patient_demographics.item(0).getAttributes.getLength;

        A = [];
        for j = 0:k-1
        A{j+1} = char(patient_demographics.item(0).getAttributes.item(j));
        end

        % Find Date
        
        for j = 1:k
            if strcmp(A{j}(1:4),'date')
                datestr = A{j};
            end
             if strcmp(A{j}(1:4),'time')
                timestr = A{j};
             end
        end

        M.Date = datestr(7:16);
        M.Time = timestr(7:14);

    catch ME
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
case 'hl7_xml'

    X = readstruct(filename);

% Sex
    try 
        M.Sex = X.componentOf.timepointEvent.componentOf.subjectAssignment.subject.trialSubject.subjectDemographicPerson.administrativeGenderCode.codeAttribute;
    catch ME
    end

% Age
    try 
        age  = X.controlVariable.relatedObservation.value.valueAttribute;

        if isnumeric(age) & strcmp(X.controlVariable.relatedObservation.code.codeAttribute, "21612-7")
            M.Age = X.controlVariable.relatedObservation.value.valueAttribute;
        end    
    catch ME
    end

% DOB
    try 
        M.PatientID = X.componentOf.timepointEvent.componentOf.subjectAssignment.subject.trialSubject.id.rootAttribute;
    catch ME
    end

% PAtient ID
    try 
        dobstr = num2str(X.componentOf.timepointEvent.componentOf.subjectAssignment.subject.trialSubject.subjectDemographicPerson.birthTime.valueAttribute);

        % Add in dashes to DOB
        M.DOB = strcat(dobstr(1:4),"-", dobstr(5:6), "-",dobstr(7:8));
    catch ME
    end



    % Race
    try 
        racestr = X.componentOf.timepointEvent.componentOf.subjectAssignment.subject.trialSubject.subjectDemographicPerson.raceCode.codeAttribute;
    
        % Look up Race code
        % Reference https://www.amps-llc.com/uploads/2017-12-7/aECG_Implementation_Guide(1).pdf
        % Possible codes were updated since or will be updated in the future...
        switch racestr
            case '1002-5'
                M.Race = 'Native American';
            case '2028-9'
                M.Race = 'Asian';
            case '2054-5'
                M.Race = 'Black/African American';
            case '2076-8'
                M.Race = 'Hawaiian/Pacific Islander';
            case '2106-3'
                M.Race = "White";
            otherwise
                M.Race = "Other";
        end
    catch ME
    end

    % Name
    % Name can be either just in <name></name> tags or can be tags <family> or
    % <given> within the <name> tag

    try
        % Check if there is text within <name> tags
        if isstring(X.componentOf.timepointEvent.componentOf.subjectAssignment.subject.trialSubject.subjectDemographicPerson.name)
            M.Name = X.componentOf.timepointEvent.componentOf.subjectAssignment.subject.trialSubject.subjectDemographicPerson.name;
            % Remove firstname and lastname fields
            M = rmfield(M,'Firstname');
            M = rmfield(M,'Lastname');
        else
            M.Lastname = X.componentOf.timepointEvent.componentOf.subjectAssignment.subject.trialSubject.subjectDemographicPerson.name.family;
            M.Firstname = X.componentOf.timepointEvent.componentOf.subjectAssignment.subject.trialSubject.subjectDemographicPerson.name.given;
        end
    catch ME
    end

% Date/Time
    try
        timestr = num2str(X.component.series.effectiveTime.low.valueAttribute);
        M.Date = strcat(timestr(1:4),"-", timestr(5:6), "-",timestr(7:8));
        M.Time = strcat(timestr(9:10),':',timestr(11:12),':',timestr(13:14));
    catch ME
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
otherwise
% Nothing to extract - report 'N/A' for all


end   % End switch statement

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
% 
