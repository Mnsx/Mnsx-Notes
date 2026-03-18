# LeetCode

## 1. 两数之和

> 给定一个整数数组 `nums` 和一个整数目标值 `target`，请你在该数组中找出 **和为目标值** *`target`* 的那 **两个** 整数，并返回它们的数组下标。
>
> 你可以假设每种输入只会对应一个答案，并且你不能使用两次相同的元素。
>
> 你可以按任意顺序返回答案。

```c++
// 暴力法
vector<int> twoSum(vector<int>& nums, int target) {

    // 双指针，一个头一个尾遍历，等于target就返回
    for (int i = 0; i < nums.size(); ++i) {

        for (int j = i + 1; j < nums.size(); ++j) {

            if (nums[i] + nums[j] == target) {

                return {i, j};
            }
        }
    }  

    return {};
}
```

## 9. 回文数

> 给你一个整数 `x` ，如果 `x` 是一个回文整数，返回 `true` ；否则，返回 `false` 。
>
> 回文数是指正序（从左向右）和倒序（从右向左）读都是一样的整数。
>
> - 例如，`121` 是回文，而 `123` 不是。

```c++
// 暴力法
bool isPalindrome(int x) {

    // 将数字转换为字符串
    string input = to_string(x);
    int len = input.length();
    int i = 0, j = len - 1;
    // 双指针，一个头一个尾遍历，如果头尾不相同直接返回false
    while (i <= j) {

        if (input[i] != input[j]) {

            return false;
        }
        i++;
        j++;
    }
   	// 遍历完成，则说明true
    return true;
}
```

```c++
// 反转数字
bool isPalindrome(int x) {
    
    // 负数肯定不是，如果最后一位是0，那么只有0符合条件
    if (x < 0 || (x % 10 == 0 && x != 0)) {
        
        return false;
    }

    // 设置倒数字，初始为0，如果倒数字大于x，则说明已经过了中间的数字
    int revertedNumber = 0;
    while (x > revertedNumber) {
        
        // 通过x%10输出x的最后一位，然后添加倒数字中最后一位，然后x再通过x/10去除最后一位，继续
        revertedNumber = revertedNumber * 10 + x % 10;
        x /= 10;
    }
    
    // 如果是偶数个数，那么x==倒数字则说明为true，如果!=则说明为false，如果是奇数个数，那么倒数字应该比x多一位，则应该去除倒数字最后添加的一位，则倒数字/10，再与x作比较
    return x == revertedNumber || x == revertedNumber / 10;
}
```

## 13. 罗马数字转整数

>
>
>罗马数字包含以下七种字符: `I`， `V`， `X`， `L`，`C`，`D` 和 `M`。
>
>```
>字符          数值
>I             1
>V             5
>X             10
>L             50
>C             100
>D             500
>M             1000
>```
>
>例如， 罗马数字 `2` 写做 `II` ，即为两个并列的 1 。`12` 写做 `XII` ，即为 `X` + `II` 。 `27` 写做 `XXVII`, 即为 `XX` + `V` + `II` 。
>
>通常情况下，罗马数字中小的数字在大的数字的右边。但也存在特例，例如 4 不写做 `IIII`，而是 `IV`。数字 1 在数字 5 的左边，所表示的数等于大数 5 减小数 1 得到的数值 4 。同样地，数字 9 表示为 `IX`。这个特殊的规则只适用于以下六种情况：
>
>- `I` 可以放在 `V` (5) 和 `X` (10) 的左边，来表示 4 和 9。
>- `X` 可以放在 `L` (50) 和 `C` (100) 的左边，来表示 40 和 90。 
>- `C` 可以放在 `D` (500) 和 `M` (1000) 的左边，来表示 400 和 900。
>
>给定一个罗马数字，将其转换成整数。

```c++
// 暴力法
int romanToInt(string s) {
    int result = 0;
    for (int i = 0; i < s.length(); i++) {

        // 需要进行减法的判断
        if (s[i] == 'I' && i < s.length()) {

            if (s[i + 1] == 'V') {

                result -= 1;
                i++;
            } else if (s[i + 1] == 'X') {

                result -= 1;
                i++;
            }
        }
        if (s[i] == 'X' && i < s.length()) {

            if (s[i + 1] == 'L') {
                result -= 10;
                i++;
            } else if (s[i + 1] == 'C') {

                result -= 10;
                i++;
            }
        } 
        if (s[i] == 'C' && i < s.length()) {

            if (s[i + 1] == 'D') {
                result -= 100;
                i++;
            } else if (s[i + 1] == 'M') {

                result -= 100;
                i++;
            }
        }

        // 进行加法判断
        switch (s[i]) {
            case 'I':
                result += 1;
                break;
            case 'V':
                result += 5;
                break;
            case 'X':
                result += 10;
                break;
            case 'L':
                result += 50;
                break;
            case 'C':
                result += 100;
                break;
            case 'D':
                result += 500;
                break;
            case 'M':
                result += 1000;
                break;
            default:
                break;
        }
        cout << s[i] << " " << result << endl;
    }
    return result;
}
```

```C++
// 暴力法 使用unordered_map优化的方案
class Solution {
    unordered_map<char, int> map = {
        {'I', 1},
        {'V', 5},
        {'X', 10},
        {'L', 50},
        {'C', 100},
        {'D', 500},
        {'M', 1000}
    };

public:
    int romanToInt(string s) {

        int result = 0;
        for (int i = 0; i < s.size(); i++) {

            int value = map[s[i]];
            if (i < s.size() - 1 && value < map[s[i + 1]]) {
                
                result -= value;
            } else {
                result += value;
            }
        }
        return result;
    }
};
```

## 14. 最长公共前缀

> 编写一个函数来查找字符串数组中的最长公共前缀。
>
> 如果不存在公共前缀，返回空字符串 `""`。

```c++
string longestCommonPrefix(vector<string>& strs) {

    queue<char> q;

    for (int i = 0; i < strs.size(); i++) {

        int last = q.size();
        for (int j = 0; j < strs[0].size(); j++) {
            if (i == 0) {
                q.push(strs[i][j]);
                continue;
            }
            if (last == 0) {

                break;
            }

            if (q.empty()) {

                return "";
            }
            char temp = q.front();
            q.pop();
            last--;
            if (temp != strs[i][j]) {

                while (last > 0 && !q.empty()) {
                    q.pop();
                    last--;
                }
                break;
            }
            q.push(strs[i][j]);
        }
    }

    string res;
    while (!q.empty()) {
        res += q.front();
        q.pop();
    }
    return res;
}
```

## 20. 有效的括号

> 给定一个只包括 `'('`，`')'`，`'{'`，`'}'`，`'['`，`']'` 的字符串 `s` ，判断字符串是否有效。
>
> 有效字符串需满足：
>
> 1. 左括号必须用相同类型的右括号闭合。
> 2. 左括号必须以正确的顺序闭合。
> 3. 每个右括号都有一个对应的相同类型的左括号。

```c++
bool isValid(string s) {

    stack<char> stack;
    for (int i = 0; i < s.size(); i++) {

        if (s[i] == '(' || s[i] == '{' || s[i] == '[') {

            stack.push(s[i]);
        } else {

            if (stack.empty()) {

                return false;
            }

            char temp = stack.top();
            if (s[i] == ')' && temp == '(') {
                stack.pop();
            } else if (s[i] == '}' && temp == '{') {
                stack.pop();
            } else if (s[i] == ']' && temp == '[') {
                stack.pop();
            } else {
                stack.push(s[i]);
            }
        }
    }
    return stack.empty();
}
```

## 21. 合并两个有序链表

>
> 将两个升序链表合并为一个新的 **升序** 链表并返回。新链表是通过拼接给定的两个链表的所有节点组成的。 

```c++
ListNode* mergeTwoLists(ListNode* list1, ListNode* list2) {

    ListNode res(-1);
    res.next = list1;
    list1 = &res;
    while (list1->next != nullptr && list2 != nullptr) {

        if (list1->next->val < list2->val) {

            list1 = list1->next;
            continue;
        }

        ListNode * temp = list1->next;
        list1->next = list2;
        list2 = list2->next;
        list1->next->next = temp;
    }
    if (list2 != nullptr) {

        list1->next = list2;
    }

    return res.next;
}
```

## 26. 删除有序数组中的重复项

> 给你一个 **非严格递增排列** 的数组 `nums` ，请你**[ 原地](http://baike.baidu.com/item/原地算法)** 删除重复出现的元素，使每个元素 **只出现一次** ，返回删除后数组的新长度。元素的 **相对顺序** 应该保持 **一致** 。然后返回 `nums` 中唯一元素的个数。
>
> 考虑 `nums` 的唯一元素的数量为 `k`。去重后，返回唯一元素的数量 `k`。
>
> `nums` 的前 `k` 个元素应包含 **排序后** 的唯一数字。下标 `k - 1` 之后的剩余元素可以忽略。

```c++
int removeDuplicates(vector<int>& nums) {
    int j = 0;
    for (int i = 1; i < nums.size(); ++i) {

        if (nums[i] == nums[j]) {

            continue;
        }
        nums[++j] = nums[i];
    }
    return j + 1;
}
```

## 27. 移除元素

> 给你一个数组 `nums` 和一个值 `val`，你需要 **[原地](https://baike.baidu.com/item/原地算法)** 移除所有数值等于 `val` 的元素。元素的顺序可能发生改变。然后返回 `nums` 中与 `val` 不同的元素的数量。
>
> 假设 `nums` 中不等于 `val` 的元素数量为 `k`，要通过此题，您需要执行以下操作：
>
> - 更改 `nums` 数组，使 `nums` 的前 `k` 个元素包含不等于 `val` 的元素。`nums` 的其余元素和 `nums` 的大小并不重要。
> - 返回 `k`。

```c++
class Solution {
public:
    int removeElement(vector<int>& nums, int val) {

        int i = 0;
        for (int j = 0; j < nums.size(); j++) {

            if (nums[j] == val) {

                continue;
            }
            nums[i++] = nums[j];
        }
        return i;
    }
};
```

## 28. 找到字符串中第一个匹配项的下标

> 给你两个字符串 `haystack` 和 `needle` ，请你在 `haystack` 字符串中找出 `needle` 字符串的第一个匹配项的下标（下标从 0 开始）。如果 `needle` 不是 `haystack` 的一部分，则返回 `-1` 。

```c++
int strStr(string haystack, string needle) {
    int i, j = 0;
    for (int i = 0; i < haystack.size(); i++) {
        if (haystack[i] == needle[j]) {
            j++;
            if (j == needle.size()) {

                return i - j + 1;
            }
        } else {

            i = i - j;
            j = 0;
        }
    }
    return -1;
}
```

## 283. 移动零

> 给定一个数组 `nums`，编写一个函数将所有 `0` 移动到数组的末尾，同时保持非零元素的相对顺序。
>
> **请注意** ，必须在不复制数组的情况下原地对数组进行操作。
