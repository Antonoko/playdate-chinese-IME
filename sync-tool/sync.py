import os
import subprocess
import json
import datetime
import shutil
from typing import Literal
import pandas as pd
from openpyxl import Workbook
from openpyxl.utils.dataframe import dataframe_to_rows

mode = 0

def print_title():
    clear_screen()
    print("""

    notes 是一款运行在 playdate® 上的中文便签应用。
        
    通过以下步骤，本工具可以将便签数据导出为 Excel 表格文件：

    1. 将 playdate® 设置为“数据传输模式”：
        Settings → System → Reboot to Data Disk → 通过数据线连接到电脑上

    2. 打开设备目录：Data/com.haru.notes2，将其中的 data.json 做如下操作

    -------------------------------------------------------------------
          
""")
    
def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def press_any_key_to_continue():
    input("按任意键继续...")

def open_file(filename):
    '''使用系统默认应用程序打开文件'''
    if os.name == 'nt':  # Windows
        os.startfile(filename)
    elif os.name == 'posix':  # MacOS or Linux
        subprocess.call(['open', filename])
    else:
        print("Unsupported operating system")

# 存读缓存值
def get_cache_dict(key_operate, value_operate=None, operation: Literal["read", "write"] = "read", filepath="cache.json"):
    if operation == "read":
        res = read_json_as_dict_from_path(filepath)
        try:
            return res[key_operate]
        except KeyError:
            return None
        except TypeError:
            return None
    if operation == "write":
        if value_operate is not None:
            res = read_json_as_dict_from_path(filepath)
            if res is None:
                res = {key_operate: value_operate}
            else:
                res[key_operate] = value_operate
            save_dict_as_json_to_path(res, filepath)


def save_dict_as_json_to_path(data: dict, filepath):
    """将 dict 保存到 json"""
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(data, f)


def read_json_as_dict_from_path(filepath):
    """从 json 读取 dict"""
    if not os.path.exists(filepath):
        return None

    with open(filepath, "r", encoding="utf-8") as f:
        data = json.load(f)
    return data


def turn_str_lst(str:str):
    lst = []
    str = str.replace("\\n", "嚻")
    for i in str:
        lst.append(i)

    lst2 = []
    for i in lst:
        if i == "嚻":
            lst2.append("\\n")
        else:
            lst2.append(i)
    return lst2


def init():
    if not os.path.exists("backup"):
        os.makedirs("backup")


# --------------------------------------------------------------------------------------

def switch_mode():
    global mode
    while(True):
        print_title()
        print("""
        请选择操作项，输入数字后回车确认：

        1. 将 data.json 转为 xlsx （Excel 表格）进行编辑
        2. 将 xlsx （Excel 表格）文件转为 data.json 以传回 playdate®
              
        """)

        input_num = input("> ")
        if input_num == "1":
            mode = 1
            break
        elif input_num =="2":
            mode = 2
            break


def json_to_xls():
    global mode
    while(True):
        print_title()
        print("""
        请将 data.json 文件拖入到窗口中，然后回车确认：
            
        """)
        input_json_filepath = input("> ")
        if not os.path.exists(input_json_filepath):
            print("""
            似乎文件不存在……
""")
            press_any_key_to_continue()
        else:
            break
    
    try:
        shutil.copy(input_json_filepath, os.path.join("backup", os.path.basename(input_json_filepath)+datetime.datetime.strftime(datetime.datetime.now(), "%Y%m%d%H%M%S")))

        with open(input_json_filepath, "r", encoding="utf-8") as f:
            data_json = json.load(f)
        
        get_cache_dict(
                key_operate="invert_color",
                value_operate=data_json["invert_color"],
                operation="write",
            )
        get_cache_dict(
                key_operate="user_custom_name",
                value_operate=data_json["user_custom_name"],
                operation="write",
            )
        get_cache_dict(
                key_operate="theme_selection",
                value_operate=data_json["theme_selection"],
                operation="write",
            )
        df_note = pd.DataFrame(columns=["time", "note"])
        for note in data_json["user_notes"]:
            df_note.loc[len(df_note)] = [note["time"], ''.join(note["note"])]

        wb = Workbook()
        ws = wb.active
        for r in dataframe_to_rows(df_note, index=False, header=True):
            ws.append(r)
        ws.column_dimensions['A'].width = 25
        ws.column_dimensions['B'].width = 100
        
        save_name = "note_" + datetime.datetime.strftime(datetime.datetime.now(), "%Y%m%d%H%M%S") + ".xlsx"
        wb.save(save_name)
        # df_note.to_excel(save_name, index=False)
        print("""

            转换完成！请查看目录下的 {save_name} 文件。
""")
        open_file(save_name)
    except Exception as e:
        print(f"转换似乎失败了，报错原因：{e}")
    
    press_any_key_to_continue()
    mode = 0


def xls_to_json():
    global mode
    while(True):
        print_title()
        print("""
        请将 *.xlsx （Excel 表格文件）拖入到窗口中，然后回车确认：
            
        """)
        input_json_filepath = input("> ")
        if not os.path.exists(input_json_filepath):
            print("""
            似乎文件不存在……
""")
            press_any_key_to_continue()
        else:
            break
    
    try:
        df_note = pd.read_excel(input_json_filepath)
        note_lst = []
        for index, row in df_note.iterrows():
            note_dict = {}
            note_dict["time"] = row["time"]
            note_dict["note"] = turn_str_lst(row["note"])
            note_lst.append(note_dict)
        dict_to_write = {}
        dict_to_write["user_notes"] = note_lst
        if os.path.exists("cache.json"):
            dict_to_write["invert_color"] = get_cache_dict(
                key_operate="invert_color", operation="read"
            )
            dict_to_write["user_custom_name"] = get_cache_dict(
                key_operate="user_custom_name", operation="read"
            )
            dict_to_write["theme_selection"] = get_cache_dict(
                key_operate="theme_selection", operation="read"
            )
        if os.path.exists("data.json"):
            os.remove("data.json")
        save_dict_as_json_to_path(dict_to_write, "data.json")
        print("""
                已转换，请检查目录下的 data.json 并将其覆盖替换 playdate® 对应目录的 data.json。
    """)
    except Exception as e:
        print(f"转换似乎失败了，报错原因：{e}")

    press_any_key_to_continue()
    mode = 0





if __name__ == "__main__":
    init()
    while(True):
        if mode == 0:
            switch_mode()
        elif mode == 1:
            json_to_xls()
        elif mode == 2:
            xls_to_json()