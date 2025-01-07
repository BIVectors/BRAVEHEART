%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRAVEHEART - Open source software for electrocardiographic and vectorcardiographic analysis
% xml_demographics.m -- Extract age and gender from MUSE and Philips XML
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


function M = xml_demographics(filename, ecg_string)

M = struct;

% Deal with parsing issues with xmlread
% Create Document Builder
builder = javax.xml.parsers.DocumentBuilderFactory.newInstance;

% Disable dtd validation
builder.setFeature('http://apache.org/xml/features/nonvalidating/load-external-dtd', false);

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

    % Read the xml file
    tree = xmlread(filename, builder);

    patient_demographics = tree.getElementsByTagName('PatientDemographics');

    % Name
    try
        M.Lastname = char(patient_demographics.item(0).getElementsByTagName('PatientLastName').item(0).getFirstChild.getNodeValue);
    catch ME
    end

    try
        M.Firstname = char(patient_demographics.item(0).getElementsByTagName('PatientFirstName').item(0).getFirstChild.getNodeValue);
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

    % Read the xml file
    tree = xmlread(filename, builder);

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

    X = readstruct(filename);

    try 
        M.Firstname = X.patient.generalpatientdata.name.firstname;
    catch ME
    end

    try 
        M.Lastname = X.patient.generalpatientdata.name.lastname;
    catch ME
    end

    try 
        M.PatientID = string(X.patient.generalpatientdata.MRN);
    catch ME
    end

    try 
        M.DOB = X.patient.generalpatientdata.age.dateofbirth;
    catch ME
    end

    try
        M.Age =  X.patient.generalpatientdata.age.years;
    catch ME
    end
     
    try 
        M.Sex = X.patient.generalpatientdata.sex;
    catch ME
    end

    try 
        M.Race = X.patient.generalpatientdata.race.Text
    catch ME
    end

    try 
        M.Date = X.dataacquisition.dateAttribute;
        M.Time = X.dataacquisition.timeAttribute;
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

% PatientID
    try 
        M.PatientID = X.componentOf.timepointEvent.componentOf.subjectAssignment.subject.trialSubject.id.rootAttribute;
    catch ME
    end

% DOB
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
            M.Lastname = X.componentOf.timepointEvent.componentOf.subjectAssignment.subject.trialSubject.subjectDemographicPerson.name.family.Text;
            M.Firstname = X.componentOf.timepointEvent.componentOf.subjectAssignment.subject.trialSubject.subjectDemographicPerson.name.given.Text;
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
case 'schiller_xml'

    % Read XML into a structure
    X = readstruct(filename);
    D = X.patdata;
    T = X.examdescript;

    M.Firstname = D.firstname;
    M.Lastname = D.lastname;
    M.PatientID = D.id;
    dob_str = num2str(D.birthdate);
    M.Sex = D.gender;
    M.Race = D.ethnic;

    datestr = num2str(T.startdatetime.date);
    M.Time = T.startdatetime.time;      % Don't know exactly how time is formatted so leave it alone

    % Reformat DOB and Date
    M.Date = strcat(datestr(1:4),"-", datestr(5:6), "-",datestr(7:8));
    M.DOB = strcat(dob_str(1:4),"-", dob_str(5:6), "-",dob_str(7:8));

    % Calculate age based on date and DOB
    date_ecg = datetime(str2num(datestr(1:4)),str2num(datestr(5:6)),str2num(datestr(7:8)));
    date_dob = datetime(str2num(dob_str(1:4)),str2num(dob_str(5:6)),str2num(dob_str(7:8)));

    % Calculate Age
    % Subtracting 2 datetimes gives result in Hours
    M.Age = floor(hours(date_ecg - date_dob) / (365.25 * 24));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
case 'DICOM'
    
    D = dicominfo(filename);

    try
    M.Sex = D.PatientSex;
    catch ME
    end
    
    try
    agestr = D.PatientAge;
    M.Age = str2num(regexprep(agestr,'[a-zA-Z]',''));
    catch ME
    end

    try
    dobstr = char(D.PatientBirthDate);
    M.DOB = strcat(dobstr(1:4),"-", dobstr(5:6), "-",dobstr(7:8));
    catch ME
    end

    try
    M.Lastname = D.PatientName.FamilyName;
    catch ME
    end

    try
    M.Firstname = D.PatientName.GivenName;
    catch ME
    end

    try
    M.PatientID = D.PatientID;
    catch ME
    end
    
    try
    datestr = D.StudyDate;
    M.Date = strcat(datestr(1:4),"-", datestr(5:6), "-",datestr(7:8));
    catch ME
    end

    try
    timestr = D.StudyTime;
    M.Time = strcat(timestr(1:2),":", timestr(3:4), ":",timestr(5:6));
    catch ME
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
otherwise
% Nothing to extract - report 'N/A' for all


end   % End switch statement


% Reorder
if length(fieldnames(M)) == 10
    [M,~] = orderfields(M,{'Filename', 'PatientID', 'Firstname', 'Lastname', 'DOB', 'Age', 'Sex', 'Race', 'Date', 'Time'}) ;
else
    [M,~] = orderfields(M,{'Filename', 'PatientID', 'Name', 'DOB', 'Age', 'Sex', 'Race', 'Date', 'Time'}) ;
end



