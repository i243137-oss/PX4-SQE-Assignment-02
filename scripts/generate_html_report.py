import re
import os

script_dir = os.path.dirname(os.path.abspath(__file__))
repo_root = os.path.abspath(os.path.join(script_dir, ".."))

info_file = os.path.join(repo_root, "evidence/coverage/final/failsafe_student_scope.info")
out_html_dir = os.path.join(repo_root, "evidence/coverage/final/html")
os.makedirs(out_html_dir, exist_ok=True)

# Parse info file
files = {}
with open(info_file, 'r') as f:
    records = f.read().split("end_of_record")

for rec in records:
    if not rec.strip(): continue
    sf = re.search(r"SF:(.*)", rec).group(1)
    lf = int(re.search(r"LF:(\d+)", rec).group(1))
    lh = int(re.search(r"LH:(\d+)", rec).group(1))
    brf = int(re.search(r"BRF:(\d+)", rec).group(1))
    brh = int(re.search(r"BRH:(\d+)", rec).group(1))
    fnf = int(re.search(r"FNF:(\d+)", rec).group(1)) if re.search(r"FNF:(\d+)", rec) else 0
    fnh = int(re.search(r"FNH:(\d+)", rec).group(1)) if re.search(r"FNH:(\d+)", rec) else 0
    
    files[sf] = {
        'lf': lf, 'lh': lh, 'brf': brf, 'brh': brh, 'fnf': fnf, 'fnh': fnh
    }

total_lf = sum(v['lf'] for v in files.values())
total_lh = sum(v['lh'] for v in files.values())
total_brf = sum(v['brf'] for v in files.values())
total_brh = sum(v['brh'] for v in files.values())
total_fnf = sum(v['fnf'] for v in files.values())
total_fnh = sum(v['fnh'] for v in files.values())

index_html = f"""<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html lang="en">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <title>LCOV - failsafe_student_scope.info</title>
  <style>
    body {{ font-family: sans-serif; background-color: #ffffff; color: #000000; margin: 20px; }}
    h1 {{ font-size: 20px; }}
    table {{ border-collapse: collapse; width: 100%; margin-top: 15px; }}
    th, td {{ border: 1px solid #cccccc; padding: 6px 10px; text-align: left; }}
    th {{ background-color: #e0e0e0; }}
    .header {{ font-weight: bold; background-color: #f2f2f2; }}
    .high {{ background-color: #d4edda; color: #155724; font-weight: bold; }}
    .med {{ background-color: #fff3cd; color: #856404; font-weight: bold; }}
    .low {{ background-color: #f8d7da; color: #721c24; font-weight: bold; }}
  </style>
</head>
<body>
  <h1>PX4 Failsafe State Machine - Structural Coverage Report</h1>
  <p><b>Tracefile:</b> failsafe_student_scope.info</p>
  <p><b>Scope:</b> <code>framework.h</code> and <code>framework.cpp</code></p>
  <table>
    <tr class="header">
      <th>Source File</th>
      <th>Line Coverage</th>
      <th>Branch Coverage</th>
      <th>Function Coverage</th>
    </tr>
"""

for path, data in files.items():
    fname = os.path.basename(path)
    l_pct = (data['lh'] / data['lf'] * 100) if data['lf'] > 0 else 0
    b_pct = (data['brh'] / data['brf'] * 100) if data['brf'] > 0 else 0
    f_pct = (data['fnh'] / data['fnf'] * 100) if data['fnf'] > 0 else 0
    
    l_cls = "high" if l_pct >= 85 else ("med" if l_pct >= 70 else "low")
    b_cls = "high" if b_pct >= 85 else ("med" if b_pct >= 70 else "low")
    f_cls = "high" if f_pct >= 85 else ("med" if f_pct >= 70 else "low")
    
    index_html += f"""    <tr>
      <td><b>{fname}</b><br><small>{path}</small></td>
      <td class="{l_cls}">{l_pct:.1f}% ({data['lh']}/{data['lf']})</td>
      <td class="{b_cls}">{b_pct:.1f}% ({data['brh']}/{data['brf']})</td>
      <td class="{f_cls}">{f_pct:.1f}% ({data['fnh']}/{data['fnf']})</td>
    </tr>
"""

tot_l_pct = (total_lh / total_lf * 100) if total_lf > 0 else 0
tot_b_pct = (total_brh / total_brf * 100) if total_brf > 0 else 0
tot_f_pct = (total_fnh / total_fnf * 100) if total_fnf > 0 else 0

tot_l_cls = "high" if tot_l_pct >= 85 else ("med" if tot_l_pct >= 70 else "low")
tot_b_cls = "high" if tot_b_pct >= 85 else ("med" if tot_b_pct >= 70 else "low")
tot_f_cls = "high" if tot_f_pct >= 85 else ("med" if tot_f_pct >= 70 else "low")

index_html += f"""    <tr class="header">
      <td><b>Total Combined</b></td>
      <td class="{tot_l_cls}">{tot_l_pct:.1f}% ({total_lh}/{total_lf})</td>
      <td class="{tot_b_cls}">{tot_b_pct:.1f}% ({total_brh}/{total_brf})</td>
      <td class="{tot_f_cls}">{tot_f_pct:.1f}% ({total_fnh}/{total_fnf})</td>
    </tr>
  </table>
</body>
</html>
"""

with open(os.path.join(out_html_dir, "index.html"), 'w') as f:
    f.write(index_html)

print("Generated HTML report in", out_html_dir)
