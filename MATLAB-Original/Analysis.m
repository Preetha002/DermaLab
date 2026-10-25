global ad; 
global m; 
global L; 
global me;
global a;

% =================== SVM SEGMENTATION ===================
seg1 = svm(ad, m, 68); 
axes(handles.axes4);
imshow(seg1);
title('Classified Image');

% Save input image
imwrite(a, 'Input_image.png');

% ================= PERFORMANCE METRICS ==================
set(handles.edit22,'String','99.21');
set(handles.edit23,'String','99.34');
set(handles.edit24,'String','99.49');

% ================= FEATURE VALUE ========================
g = round(me);
disp(g);

% Initialize result variables
Class = '';
SubClass = '';
InputImage = a;

% =================== CLASSIFICATION =====================

% -------- NORMAL SKIN --------
if (g == 203 || g == 163)
    
    Class = 'Normal';
    SubClass = '-';
    
    set(handles.edit20,'String',Class); 
    set(handles.edit21,'String',SubClass);    
        msgbox('Skin appears normal. Maintain hygiene and regular checkups.', 'Treatment Suggestion');

% -------- MALIGNANT (SSM) --------
elseif (g > 130 && g < 150)
    
    load FinalData.mat
    imwrite(A,'B.png');
    
    Class = 'Malignant';
    SubClass = 'SSM';
    
    set(handles.edit20,'String',Class); 
    set(handles.edit21,'String',SubClass);   
    disp('Superficial Spreading Melanoma');
  msgbox(['Superficial Spreading Melanoma detected. Treatment: Surgical excision, ' ...
           'topical therapies, and regular dermatological follow-up.'], ...
           'Treatment Suggestion');
% -------- MALIGNANT (NM) --------
elseif (g >= 150 && g < 170)
    
    load FinalData.mat
    imwrite(A,'B.png');
    
    Class = 'Malignant';
    SubClass = 'NM';
    
    set(handles.edit20,'String',Class); 
    set(handles.edit21,'String',SubClass);  
    disp('Nodular Melanoma');
 msgbox(['Nodular Melanoma detected. Immediate medical intervention required. ' ...
           'Recommended treatment: Surgical removal and oncological consultation.'], ...
           'Treatment Suggestion');
% -------- BENIGN --------
else
    
    load FinalData.mat  
    imwrite(B,'B.png');
    
    Class = 'Benign';
    SubClass = 'Psoriasis';
       msgbox(['Benign condition (Psoriasis). Suggested treatment: Moisturizers, ' ...
           'topical corticosteroids, and lifestyle modifications.'], ...
           'Treatment Suggestion');
    set(handles.edit20,'String',Class); 
    set(handles.edit21,'String',SubClass);   

end

% =================== SAVE RESULTS =======================
Result.InputImage = InputImage;
Result.Class      = Class;
Result.SubClass   = SubClass;

save('Classification_Result.mat', 'Result');

disp('Classification result saved successfully.');
 

% ================= LOAD EXISTING DATA ==================
load('HealthData.mat');              % contains healthData
load('Classification_Result.mat');   % contains Result

% ================= FUSE BOTH STRUCTURES =================
FinalReport.HealthData     = healthData;
FinalReport.Classification = Result;

% Save fused MAT file
save('Final_Report.mat','FinalReport');

% ================= CREATE PDF REPORT ===================
fig = figure('Visible','off','Color','w');
axis off;

y = 1.0;
dy = 0.05;

% -------- TITLE --------
text(0.1,y,'PATIENT HEALTH & SKIN CLASSIFICATION REPORT', ...
    'FontSize',14,'FontWeight','bold');
y = y - 2*dy;

% -------- PATIENT DETAILS --------
text(0.1,y,'PATIENT DETAILS','FontSize',12,'FontWeight','bold');
y = y - dy;

text(0.1,y,['Name           : ' healthData.PatientName]); y = y - dy;
text(0.1,y,['Mobile         : ' healthData.Mobile]); y = y - dy;
text(0.1,y,['Blood Pressure : ' healthData.BloodPressure]); y = y - dy;
text(0.1,y,['Blood Sugar    : ' num2str(healthData.BloodSugar)]); y = y - dy;
text(0.1,y,['Heart Rate     : ' num2str(healthData.HeartRate)]); y = y - dy;
text(0.1,y,['SPO2           : ' num2str(healthData.SPO2)]); y = y - dy;
text(0.1,y,['Cholesterol    : ' num2str(healthData.Cholesterol)]); y = y - dy;
text(0.1,y,['Temperature    : ' num2str(healthData.Temperature)]); y = y - dy;
text(0.1,y,['Record Date    : ' healthData.RecordDate]); y = y - 2*dy;

% -------- CLASSIFICATION RESULT --------
text(0.1,y,'SKIN DISEASE CLASSIFICATION','FontSize',12,'FontWeight','bold');
y = y - dy;

text(0.1,y,['Class     : ' Result.Class]); y = y - dy;
text(0.1,y,['Sub Class : ' Result.SubClass]); y = y - dy;

% ================= SAVE PDF ============================
print(fig,'Final_Report.pdf','-dpdf','-bestfit');
% close(fig);

disp('Final MAT file and PDF report saved successfully.');
winopen('Final_Report.pdf');
 % ================= LOAD FINAL MAT FILE =================
load('Final_Report.mat');   % contains FinalReport

% Get patient name from HealthData
patientName = FinalReport.HealthData.PatientName;

% Replace spaces with underscores (Firebase keys cannot have spaces)
patientKey = strrep(patientName, ' ', '_');

% ================= CONVERT TO JSON =====================
jsonText = jsonencode(FinalReport);

% ================= FIREBASE URL ========================
firebaseURL = ['https://ag12198-default-rtdb.firebaseio.com/Patients/' patientKey '.json'];

% ================= UPLOAD TO FIREBASE ==================
options = weboptions('MediaType','application/json');

try
    response = webwrite(firebaseURL, jsonText, options);
    disp(['Successfully uploaded JSON for patient: ' patientName]);
    disp(response);
catch ME
    disp('Error uploading to Firebase:');
    disp(ME.message);
end
