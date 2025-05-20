# TPF College Student Database System

## Scenario:
Requirement to create an online college database where details of students are added.

## User Case:

### 1. Add Student Details to College Database:

Details include:
- **Students Name**
- **Age**
- **Phone Number**
- **Residential Address**
- **Branch** (Commerce/Science/Arts)
- **4 Mandatory Subjects Chosen** from respective branches

### List of Subjects for Each Branch:
- **Commerce:** Business Law, Economics, Maths, Tally, Language, Accountancy, and Business Studies.
- **Science:** Maths, Physics, Economics, Biology, Information Technology, and Language.
- **Arts:** History, Sociology, Geography, Fine Arts, Music, Political Science, Geography, Computer Science, Regional Language, and Physical Education.

**Branch Codes:**
- Commerce: `CME`
- Science: `SCI`
- Arts: `ART`

**Roll Number:** Range from 1-256.

**PAC (Primary Action Code):**
- Add: `A/`
- Update: `U/`
- Display: `*/`
- Delete: `D/`

### 2. Display Student’s Details:
- By name or roll number and department.

### 3. Update Student Details.

### 4. Delete Student Details.

## Program Level Flow:

### 1. **Driver Program (AAA.asm):**
- Validating entry and authorization to access the database.
- This program will call other programs for various operations.

### 2. **Add/Update Program (BBBB.asm):**
- Add/update student details as passed on by the driver program.

### 3. **Display Program (CCCC.asm):**
- Display student’s details.

### 4. **Delete Program (DDDD.asm):**
- Delete student details.

### Data Macros:
1. **ADDAT.mac:** Long-term pool file to add each student’s details.
2. **COLLEGEDATAx.mac**

## Entry Format:

### Branch Codes:
- Commerce: `"CME"`
- Science: `"SCI"`
- Arts: `"ART"`

**Roll Number Range:** 1-256.

**PAC (Primary Action Code):**
- Add: `A/`
- Update: `U/`
- Display: `*/`
- Deletion: `D/`

### Add Details (PAC = `A/`):

Example Format:
- `A/Students Name/Age/Phone no/Residential Address/Branch/Subjects`

### Validation on Entry Details:
1. **Students Name:** Alpha characters and spaces only. Maximum name length: 15 characters.
2. **Age:** Number format (max 2 digits).
3. **Phone Number:** Number format (max 10 digits).
4. **Residential Address:** Alphanumeric characters, special characters allowed: space, slash, hyphen. Maximum address length: 40 characters. Address must be enclosed in brackets.
5. **Branch:** Must be a valid branch code (CME, SCI, ART).
6. **Subjects:** Must be valid subjects as per the selected branch (see list of subjects for each branch).

**Invalid Entries:**
- **Example 1:** `A/ANAND RAJENDRAN/37/6380462795/(3-10 MAIN ROAD THALUTHALAI PERAMBALUR)/CME/Business law, Economics, Maths, Tally` → Successfully added to the database.
- **Example 2:** `A/ANAND RAJENDRANNNNNN/37/63804622795/(3-10 MAIN ROAD THALUTHALAI PERAMBALUR)/CME/Business law, Economics, Maths, Tally` → Invalid Entry: Name too long.
- **Example 3:** `A/ANAND RAJENDRAN1/37/63804622795/(3-10 MAIN ROAD THALUTHALAI PERAMBALUR)/CME/Business law, Economics, Maths, Tally` → Invalid Entry: Name contains numeric characters.
- **Example 4:** `A/ANAND RAJENDRAN/371/63804622795/(3-10 MAIN ROAD THALUTHALAI PERAMBALUR)/CME/Business law, Economics, Maths, Tally` → Invalid Entry: Age incorrect.
- **Example 5:** `A/ANAND RAJENDRAN/3A/63804622795/(3-10 MAIN ROAD THALUTHALAI PERAMBALUR)/CME/Business law, Economics, Maths, Tally` → Invalid Entry: Age contains non-numeric characters.
- **Example 6:** `A/ANAND RAJENDRAN/37/638046227950/(3-10 MAIN ROAD THALUTHALAI PERAMBALUR)/CME/Business law, Economics, Maths, Tally` → Invalid Entry: Phone number incorrect.
- **Example 7:** `A/ANAND RAJENDRAN/37/6380462279A/(3-10 MAIN ROAD THALUTHALAI PERAMBALUR)/CME/Business law, Economics, Maths, Tally` → Invalid Entry: Phone number contains invalid characters.
- **Example 8:** `A/ANAND RAJENDRAN/37/63804622795/(3-10 &&&&&&THALUTHALAI PERAMBALUR)/CME/Business law, Economics, Maths, Tally` → Invalid Entry: Address contains invalid characters.
- **Example 9:** `A/ANAND RAJENDRAN/37/63804622795/(3-10 MAIN ROAD THALUTHALAI PERAMBALURRRRRRRRRRRR)/CME/Business law, Economics, Maths, Tally` → Invalid Entry: Address exceeds maximum length.
- **Example 10:** `A/ANAND RAJENDRAN/37/63804622795/(3-10 MAIN ROAD THALUTHALAI PERAMBALUR)/CMP/Business law, Economics, Maths, Tally` → Invalid Entry: Course code incorrect.
- **Example 11:** `A/ANAND RAJENDRAN/37/63804622795/(3-10 MAIN ROAD THALUTHALAI PERAMBALUR)/CME/Business law, Economics, ENGLISH, Tally` → Invalid Entry: Subject incorrect.
- **Example 12:** `A/ANAND RAJENDRAN/37/63804622795/(3-10 MAIN ROAD THALUTHALAI PERAMBALUR)/CMP/Business law, Economics, Maths` → Invalid Entry: Missing subjects.
- **Example 13:** `A/37/63804622795/(3-10 MAIN ROAD THALUTHALAI PERAMBALUR)/CMP/Business law, Economics, Maths, Tally` → Invalid Entry: Name missing.

### Same validation process applies to other fields such as age, phone number, address, and subject choice.

## Updation:

For Updation, any one of the following parameters is mandatory for mapping:
- **Name**
- **Phone Number**
- **Roll Number**

**Mapping:** Mapping happens based on the course, which is the primary mandatory field. Name, Phone number, and Roll number are secondary fields.

### Examples:
- **Example 1:** `U/ART/13-ANAND RAJENDRAN/28/6380462795/(3-10 MAIN ROAD THALUTHALAI PERAMBALUR)/CME/Business law, Economics, Maths, Tally` → Updated Successfully (Updation via Roll Number).
- **Example 2:** `U/ART/ANAND RAJENDRAN-ANAND RAJA/37/6380462795/(3-10 MAIN ROAD THALUTHALAI PERAMBALUR)/CME/Business law, Economics, Maths, Tally` → Updated Successfully (Updation via Name).
- **Example 3:** `U/SCI/6380462795-ANAND RAJENDRAN/37/6380462795/(3-11 MAIN ROAD THALUTHALAI PERAMBALUR)/CME/Business law, Economics, Maths, Tally` → Updated Successfully (Updation via Mobile Number).
- **Example 4:** `U/ART/13-///7665662212//` → Only updating phone field.

### Special Case:
If a branch changes, the record needs to be removed from the original branch and added to the new branch.

## Display:

### Examples:
- **Display with Branch and Roll Number:** `*/ART/13`
- **Display with Branch and Student’s Name:** `*/SCI/ABCD`

Branch is the primary mandatory field, Roll Number and Name are secondary fields.

## Deletion:

### Examples:
- **Delete with Branch and Roll Number:** `D/ART/13`
- **Delete with Branch and Student’s Name:** `D/SCI/ABCD`

Branch is the primary mandatory field, Roll Number and Name are secondary fields.

## Create DSECT with Values:

### Structure:
- **200-byte DSECT:**
    - 10 bytes for total record count and other requirements.
    - **Total Length:** 190 bytes per record.

**Record Structure:**
- Roll Number: 2 bytes
- Student’s Name: Maximum 15 characters
- Age: Maximum 2 digits
- Phone Number: Maximum 10 digits
- Residential Address: Maximum 40 characters
- Course: 3 bytes
- Subject 1: Maximum 20 characters
- Subject 2: Maximum 20 characters
- Subject 3: Maximum 20 characters
- Subject 4: Maximum 20 characters
- Spare: Remaining bytes.

## Pool File Management:
- Each branch has an ordinal number.
- Inside the fixed file, create a pool file for saving student records.
- Once the record size is full, create another pool file and link it to the previous one via a forward chain.
- This structure follows a chaining mechanism for continuous storage.

## Summary:

- **Driver Program (AAA.asm):** Handles validation, entry, and routes operations to other programs.
- **Add/Update Program (BBBB.asm):** Handles the adding and updating of student data.
- **Display Program (CCCC.asm):** Displays student details based on criteria.
- **Delete Program (DDDD.asm):** Deletes student records based on criteria.
- **Pool Files:** Used for storing student data, with a chaining mechanism to manage multiple pool files.