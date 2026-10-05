import re
import os
import sys

def parse_gcov(gcov_path, source_file):
    lines_data = [] # (line_num, count)
    branches_data = [] # (line_num, block_num, branch_num, count)
    funcs_data = {} # name -> (start_line, count)
    
    with open(gcov_path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.readlines()
        
    current_line = 0
    branch_idx = 0
    
    for l in content:
        # Check function
        m_fn = re.match(r"^function\s+(.*?)\s+called\s+(\d+)", l)
        if m_fn:
            fname = m_fn.group(1)
            fcount = int(m_fn.group(2))
            funcs_data[fname] = fcount
            continue
            
        m_br = re.match(r"^branch\s+(\d+)\s+(taken\s+(\d+)|never executed)", l)
        if m_br:
            b_taken = m_br.group(3)
            taken_count = int(b_taken) if b_taken is not None else 0
            branches_data.append((current_line, branch_idx, taken_count))
            branch_idx += 1
            continue

        parts = l.split(':', 2)
        if len(parts) >= 2:
            count_str = parts[0].strip()
            line_str = parts[1].strip()
            if line_str.isdigit():
                current_line = int(line_str)
                branch_idx = 0
                if count_str != '-' and count_str != '#####':
                    if count_str.isdigit():
                        lines_data.append((current_line, int(count_str)))
                elif count_str == '#####':
                    lines_data.append((current_line, 0))

    return lines_data, branches_data, funcs_data

def write_info(out_path, files):
    with open(out_path, 'w') as out:
        out.write("TN:\n")
        for gcov_file, src_path in files:
            lines_data, branches_data, funcs_data = parse_gcov(gcov_file, src_path)
            out.write(f"SF:{src_path}\n")
            
            # Functions
            # In lcov, FN:<line>,<name>, FNDA:<count>,<name>
            fn_total = 0
            fn_hit = 0
            # If gcov has functions:
            for fname, count in funcs_data.items():
                out.write(f"FN:0,{fname}\n")
                out.write(f"FNDA:{count},{fname}\n")
                fn_total += 1
                if count > 0:
                    fn_hit += 1
            if fn_total > 0:
                out.write(f"FNF:{fn_total}\n")
                out.write(f"FNH:{fn_hit}\n")
                
            # Branches
            br_total = len(branches_data)
            br_hit = 0
            for line_num, b_idx, count in branches_data:
                taken = str(count) if count > 0 else "-"
                out.write(f"BRDA:{line_num},0,{b_idx},{taken}\n")
                if count > 0:
                    br_hit += 1
            out.write(f"BRF:{br_total}\n")
            out.write(f"BRH:{br_hit}\n")
            
            # Lines
            lh = 0
            for line_num, count in lines_data:
                out.write(f"DA:{line_num},{count}\n")
                if count > 0:
                    lh += 1
            out.write(f"LF:{len(lines_data)}\n")
            out.write(f"LH:{lh}\n")
            out.write("end_of_record\n")

if __name__ == '__main__':
    script_dir = os.path.dirname(os.path.abspath(__file__))
    repo_root = os.path.abspath(os.path.join(script_dir, ".."))
    gcov_dir = os.path.join(repo_root, "PX4-Autopilot/build/px4_sitl_test/src/modules/commander/failsafe/CMakeFiles/failsafe.dir")
    
    framework_h = os.path.join(repo_root, "PX4-Autopilot/src/modules/commander/failsafe/framework.h")
    framework_cpp = os.path.join(repo_root, "PX4-Autopilot/src/modules/commander/failsafe/framework.cpp")
    
    files = [
        (os.path.join(gcov_dir, "framework.h.gcov"), framework_h),
        (os.path.join(gcov_dir, "framework.cpp.gcov"), framework_cpp)
    ]
    out_info = os.path.join(repo_root, "evidence/coverage/final/failsafe_student_scope.info")
    write_info(out_info, files)
    print("Generated", out_info)

