# TPF College Student Database System

## Objective

Create a **college database** to:

* **Add**, **Display**, **Update**, and **Delete** student records.

---

## Program Overview

* **`AAAA.asm`**: Driver program for validation, routing, and authorization.
* **`BBBB.asm`**: Handles Add/Update operations.
* **`CCCC.asm`**: Handles Display operations.
* **`DDDD.asm`**: Handles Delete operations.

---

## Student Data Fields

| Field            | Validation                                                           |
| ---------------- | -------------------------------------------------------------------- |
| **Name**         | Max 15 characters, alphabets and spaces only                         |
| **Age**          | Numeric, max 2 digits                                                |
| **Phone Number** | Numeric, 10 digits                                                   |
| **Address**      | Alphanumeric, special chars: space, slash, hyphen, max 40 characters |
| **Course**       | One of: `CME`, `SCI`, `ART`                                          |
| **Subjects**     | 4 subjects, must be valid for the course                             |

### Valid Subjects by Course

* **Commerce**: Business Law, Economics, Maths, Tally, Language, Accountancy, and Business Studies 
* **Science**: Maths, Physics, Economics, Biology, Information Technology, and Language 
* **Arts**: History, Sociology, Geography, Fine Arts, Music, Political Science, Geography, Computer Science, Regional Language, and Physical Education 

---

## Entry Format

* **PAC** (Primary Action Code):

  * `A/` → Add
  * `U/` → Update
  * `*/` → Display
  * `D/` → Delete

### Entry Format Example

```
A/ANAND RAJENDRAN/37/6380462795/(3-10 MAIN ROAD)/CME/Business law,Economics,Maths,Tally
```

* **Validations**:

  * 6 slashes (`/`)
  * 1 pair of parentheses `()`
  * 3 commas `,`

---

## Add Entry Validation

### Invalid Cases:

1. **Name**: Max 15 characters, no digits.
2. **Age**: Numeric, max 2 digits.
3. **Phone**: 10 digits, numeric only.
4. **Address**: Max 40 characters, only alphanumeric + `/`, `-`, and space.
5. **Subjects**: Must match course, 4 subjects.

---

## Update Rules

### Update via:

1. **Name**
2. **Phone Number**
3. **Roll Number**

**Note**: Branch must be provided for update. If updating **branch**, remove from old record and add to new branch.

### Example Update Format:

```
U/ART/13-ANAND RAJENDRAN/28/6380462795/(3-10 MAIN ROAD)/CME/Business law,Economics,Maths,Tally
```

---

## Display Function

* **Format**:

  * `*/ART/13` → Display by branch and roll number
  * `*/SCI/ABCD` → Display by branch and name

---

## Delete Function

* **Format**:

  * `D/ART/13` → Delete by branch and roll number
  * `D/SCI/ABCD` → Delete by branch and name

---

## Data Structure (DSECT)

| Field        | Size      |
| ------------ | --------- |
| Roll Number  | 2         |
| Name         | 15        |
| Age          | 2         |
| Phone Number | 10        |
| Address      | 40        |
| Course       | 3         |
| Subjects (4) | 20x4      |
| Spare        | Remaining |

**Total Record Size**: 190 bytes
**Metadata**: First 10 bytes for record count and file management.

---

## Storage

* **Fixed file per branch** with pool files.
* **Forward chaining** links full pool files.

---
