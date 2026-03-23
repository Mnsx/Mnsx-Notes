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

```c++
void moveZeroes(vector<int>& nums) {

    int z = nums.size() - 1;
    for (int i = 0; i < nums.size() && i <= z; ++i) {

        if (nums[i] == 0) {

            for (int j = i; j < z; ++j) {

                nums[j] = nums[j + 1];
            }
            nums[z--] = 0;
            i--;
        }
    }
}
```

```c++
void moveZeroes(vector<int>& nums) {

    int n = nums.size(), left = 0, right = 0;
    while (right < n) {

        if (nums[right] != 0) {

            swap(nums[left], nums[right]);
            left++;
        }
        right++;
    }
}
```

## 35. 搜索插入位置

> 给定一个排序数组和一个目标值，在数组中找到目标值，并返回其索引。如果目标值不存在于数组中，返回它将会被按顺序插入的位置。
>
> 请必须使用时间复杂度为 `O(log n)` 的算法。

```c++
int searchInsert(vector<int>& nums, int target) {

    int left = 0, right = nums.size() - 1, res = 0;
    while (left < right) {

        int mid = left + (right - left) / 2;
        cout << mid << " " << left << " " << right << endl;
        if (nums[mid] > target) {

            right = mid - 1;
            res = left;
        } else if (nums[mid] < target) {

            left = mid + 1;
            res = right;
        } else {

            return mid;
        }
    }
    return target > nums[res] ? res + 1 : res;
}
```

## 344. 反转字符串

> 编写一个函数，其作用是将输入的字符串反转过来。输入字符串以字符数组 `s` 的形式给出。
>
> 不要给另外的数组分配额外的空间，你必须**[原地](https://baike.baidu.com/item/原地算法)修改输入数组**、使用 O(1) 的额外空间解决这一问题。

```c++
void reverseString(vector<char>& s) {

    int left = 0, right = s.size() - 1;
    while (left < right) {

        swap(s[left++], s[right--]);
    }
}
```

## 541. 反转字符串 II

> 给定一个字符串 `s` 和一个整数 `k`，从字符串开头算起，每计数至 `2k` 个字符，就反转这 `2k` 字符中的前 `k` 个字符。
>
> - 如果剩余字符少于 `k` 个，则将剩余字符全部反转。
> - 如果剩余字符小于 `2k` 但大于或等于 `k` 个，则反转前 `k` 个字符，其余字符保持原样。

```c++
string reverseStr(string s, int k) {
    int cur = 0, left = 0, right = k - 1;
    int flag = 0;
    while (right < s.size()) {

        if (flag == 0) {

            while (left < right) {

                swap(s[left++], s[right--]);
            }
            flag = 1;
        } else {

            flag = 0;
        }
        cur += k;
        left = cur;
        right = left + k - 1;
    }
    if (flag == 0) {

        right = s.size() - 1;
        while (left < right) {

            swap(s[left++], s[right--]);
        }
    }
    return s;
}
```

## 125. 验证回文串

> 如果在将所有大写字符转换为小写字符、并移除所有非字母数字字符之后，短语正着读和反着读都一样。则可以认为该短语是一个 **回文串** 。
>
> 字母和数字都属于字母数字字符。
>
> 给你一个字符串 `s`，如果它是 **回文串** ，返回 `true` ；否则，返回 `false` 。

```c++
bool isPalindrome(string s) {
    if (s.size() == 0) {

        return true;
    }

    int left = 0, right = s.size() - 1;
    while (left < right) {

        while (left < right && !isdigit(s[left]) && !isupper(s[left]) && !islower(s[left])) {

            left++;
        }

        while (left < right && !isdigit(s[right]) && !isupper(s[right]) && !islower(s[right])) {

            right--;
        }

        if (s[left] <= 90 && s[left] >= 65) {

            s[left] += 32;
        }

        if (s[right] <= 90 && s[right] >= 65) {

            s[right] += 32;
        }

        if (s[left] != s[right]) {

            return false;
        }

        left++;
        right--;
    }

    return true;
}
```

## 387. 字符串中的第一个唯一字符

> 给定一个字符串 `s` ，找到 *它的第一个不重复的字符，并返回它的索引* 。如果不存在，则返回 `-1` 。

```c++
int firstUniqChar(string s) {
    unordered_map<char, int> um;
    for (int i = 0; i < s.size(); ++i) {

        um[s[i]] += 1;
    }
    for (int i = 0; i < s.size(); ++i) {

        if (um[s[i]] == 1) {

            return i;
        }
    }
    return -1;
}
```

## 349. 两个数组的交集

> 给定两个数组 `nums1` 和 `nums2` ，返回 *它们的 交集* 。输出结果中的每个元素一定是 **唯一** 的。我们可以 **不考虑输出结果的顺序** 。

```c++
vector<int> intersection(vector<int>& nums1, vector<int>& nums2) {
    sort(nums1.begin(), nums1.end());
    sort(nums2.begin(), nums2.end());
    vector<int> res;
    int i = 0, j = 0;
    while (i < nums1.size() && j < nums2.size()) {

        while (i < nums1.size() - 1 && nums1[i] == nums1[i + 1]) {

            i++;
        }
        while (j < nums2.size() - 1 && nums2[j] == nums2[j + 1]) {

            j++;
        }

        if (nums1[i] == nums2[j]) {

            res.push_back(nums1[i]);
            i++;
        } else if (nums1[i] > nums2[j]) {

            j++;
        } else {

            i++;
        }
    }
    return res;
}
```

## 167. 两数之和II - 输入有序数组

> 给你一个下标从 **1** 开始的整数数组 `numbers` ，该数组已按 **非递减顺序排列** ，请你从数组中找出满足相加之和等于目标数 `target` 的两个数。如果设这两个数分别是 `numbers[index1]` 和 `numbers[index2]` ，则 `1 <= index1 < index2 <= numbers.length` 。
>
> 以长度为 2 的整数数组 `[index1, index2]` 的形式返回这两个整数的下标 `index1` 和 `index2`。
>
> 你可以假设每个输入 **只对应唯一的答案** ，而且你 **不可以** 重复使用相同的元素。
>
> 你所设计的解决方案必须只使用常量级的额外空间。

```c++
vector<int> twoSum(vector<int>& numbers, int target) {
    int i = 0, j = numbers.size() - 1;
    while (i < j) {

        if (numbers[i] + numbers[j] == target) {

            return {i + 1, j + 1};
        } else if (numbers[i] + numbers[j] < target) {

            i++;
        } else {

            j--;
        }
    }
    return {};
}
```

## 88. 合并两个有序数组

> 给你两个按 **非递减顺序** 排列的整数数组 `nums1` 和 `nums2`，另有两个整数 `m` 和 `n` ，分别表示 `nums1` 和 `nums2` 中的元素数目。
>
> 请你 **合并** `nums2` 到 `nums1` 中，使合并后的数组同样按 **非递减顺序** 排列。
>
> **注意：**最终，合并后数组不应由函数返回，而是存储在数组 `nums1` 中。为了应对这种情况，`nums1` 的初始长度为 `m + n`，其中前 `m` 个元素表示应合并的元素，后 `n` 个元素为 `0` ，应忽略。`nums2` 的长度为 `n` 。

```c++
void merge(vector<int>& nums1, int m, vector<int>& nums2, int n) {
    int i = m - 1, j = n - 1, cur = m + n - 1;
    while (i >= 0 && j >= 0) {

        if (nums1[i] > nums2[j]) {

            nums1[cur--] = nums1[i--];
        } else {

            nums1[cur--] = nums2[j--];
        }
    }
    while (i >= 0) {

        nums1[cur--] = nums1[i--];
    }
    while (j >= 0) {
        nums1[cur--] = nums2[j--];
    }
}
```

## 53. 最大子数组和

> 给你一个整数数组 `nums` ，请你找出一个具有最大和的连续子数组（子数组最少包含一个元素），返回其最大和。
>
> **子数组**是数组中的一个连续部分。

```c++
int maxSubArray(vector<int>& nums) {
    int len = nums.size();
    int arr[len];
    for (int i = 1; i < len; ++i) {

        arr[i] = INT_MIN;
    }
    arr[0] = nums[0];
    for (int i = 1; i < len; ++i) {

        if (nums[i] + arr[i - 1] > nums[i]) {

            arr[i] = nums[i] + arr[i - 1];
        } else {

            arr[i] = nums[i];
        }
    }
    int max = INT_MIN;
    for (auto a : arr) {

        if (a > max) {

            max = a;
        }
    }
    return max;
}
```

## 121. 买股票的最佳时机

> 给定一个数组 `prices` ，它的第 `i` 个元素 `prices[i]` 表示一支给定股票第 `i` 天的价格。
>
> 你只能选择 **某一天** 买入这只股票，并选择在 **未来的某一个不同的日子** 卖出该股票。设计一个算法来计算你所能获取的最大利润。
>
> 返回你可以从这笔交易中获取的最大利润。如果你不能获取任何利润，返回 `0` 。

```c++
int maxProfit(vector<int>& prices) {
    int len = prices.size();
    int arr[len];
    arr[0] = -prices[0];
    int res = INT_MIN;
    for (int i = 1; i < len; ++i) {

        if (-prices[i] > arr[i - 1]) {

            arr[i] = -prices[i];
        } else {

            arr[i] = arr[i - 1];
        }

        if (arr[i - 1] + prices[i] > res) {

            res = arr[i - 1] + prices[i];
        }
    }
    return res > 0 ? res : 0;
}
```

## 217. 存在重复元素

> 给你一个整数数组 `nums` 。如果任一值在数组中出现 **至少两次** ，返回 `true` ；如果数组中每个元素互不相同，返回 `false` 。

```c++
bool containsDuplicate(vector<int>& nums) {
    unordered_map<int, int> um;
    for (auto num : nums) {

        um[num] += 1;
        if (um[num] > 1) {

            return true;
        }
    }
    return false;
}
```

## 704. 二分查找

> 给定一个 `n` 个元素有序的（升序）整型数组 `nums` 和一个目标值 `target` ，写一个函数搜索 `nums` 中的 `target`，如果 `target` 存在返回下标，否则返回 `-1`。
>
> 你必须编写一个具有 `O(log n)` 时间复杂度的算法。

```c++
int search(vector<int>& nums, int target) {
    int left = 0, right = nums.size() - 1;
    while (left <= right) {
        int mid = left + (right - left) / 2;
        if (nums[mid] == target) {

            return mid;
        } else if (nums[mid] > target) {

            right = mid - 1;
        } else {

            left = mid + 1;
        }
    }
    return -1;
}
```

## 69. x的平方根

> 给你一个非负整数 `x` ，计算并返回 `x` 的 **算术平方根** 。
>
> 由于返回类型是整数，结果只保留 **整数部分** ，小数部分将被 **舍去 。**
>
> **注意：**不允许使用任何内置指数函数和算符，例如 `pow(x, 0.5)` 或者 `x ** 0.5` 。

```C++
int mySqrt(int x) {
    long i = 0;
    while (1) {

        if (i * i == x) {
            return i;
        }
        if (i * i > x) {

            return i - 1;
        }
        i++;
    }
}
```

```C++
int mySqrt(int x) {
    int left = 0, right = x;
    while (left <= right) {

        long mid = left + (right - left) / 2;
        if (mid * mid == x) {

            return mid;
        } else if (mid * mid > x) {

            right = mid - 1;
            if ((mid - 1) * (mid - 1) < x) {

                return mid - 1;
            }
        } else {

            left = mid + 1;
        }
    }
    return -1;
}
```

## 278. 第一个错误的版本

> 你是产品经理，目前正在带领一个团队开发新的产品。不幸的是，你的产品的最新版本没有通过质量检测。由于每个版本都是基于之前的版本开发的，所以错误的版本之后的所有版本都是错的。
>
> 假设你有 `n` 个版本 `[1, 2, ..., n]`，你想找出导致之后所有版本出错的第一个错误的版本。
>
> 你可以通过调用 `bool isBadVersion(version)` 接口来判断版本号 `version` 是否在单元测试中出错。实现一个函数来查找第一个错误的版本。你应该尽量减少对调用 API 的次数。

```C++
int firstBadVersion(int n) {
    int left = 1, right = n, res = -1;
    while (left <= right) {

        int mid = left + (right - left) / 2;
        if (isBadVersion(mid) == true) {

            res = mid;
            right = mid - 1;
        } else {

            left = mid + 1;
        }
    }
    return res;
}
```

## 219. 存在重复元素 II

> 给你一个整数数组 `nums` 和一个整数 `k` ，判断数组中是否存在两个 **不同的索引** `i` 和 `j` ，满足 `nums[i] == nums[j]` 且 `abs(i - j) <= k` 。如果存在，返回 `true` ；否则，返回 `false` 。

```C++
bool containsNearbyDuplicate(vector<int>& nums, int k) {
    int left = 0, right = k, cur = left + 1;
    if (k > nums.size() - 1) {

        right = nums.size() - 1;
    }
    while (left < nums.size() - 1) {

        while (cur <= right) {

            if (nums[left] == nums[cur]) {

                return true;
            }
            cur++;
        }
        left++;
        right++;
        if (right > nums.size() - 1) {

            right = nums.size() - 1;
        }
        cur = left + 1;
    }
    return false;
}
```

## 136. 只出现一次的数字

> 给你一个 **非空** 整数数组 `nums` ，除了某个元素只出现一次以外，其余每个元素均出现两次。找出那个只出现了一次的元素。
>
> 你必须设计并实现线性时间复杂度的算法来解决此问题，且该算法只使用常量额外空间。

```C++
int singleNumber(vector<int>& nums) {

    unordered_map<int, int> um;
    for (auto num : nums) {

        um[num]++;
    }
    for (auto u : um) {

        if (u.second == 1) {

            return u.first;
        }
    }
    return -1;
}
```

```C++
int singleNumber(vector<int>& nums) {

    int i = 0, j = 1;
    sort(nums.begin(), nums.end());
    while (j < nums.size()) {

        if (nums[i] != nums[j]) {
            return nums[i];
        }
        i += 2;
        j += 2;
    }
    return nums[i];
}
```

```C++
int singleNumber(vector<int>& nums) {

    int res = 0;
    for (auto num : nums) {

        res ^= num;
    }
    return res;
}
```

## 209. 长度最小的子数组

> 给定一个含有 `n` 个正整数的数组和一个正整数 `target` **。**
>
> 找出该数组中满足其总和大于等于 `target` 的长度最小的 **子数组** `[numsl, numsl+1, ..., numsr-1, numsr]` ，并返回其长度**。**如果不存在符合条件的子数组，返回 `0` 。

```c++
int minSubArrayLen(int target, vector<int>& nums) {

    if (nums.size() == 1) {

        return nums[0] >= target ? 1 : 0;
    }

    int left = 0, right = 1, sum = nums[left] + nums[right], res = INT_MAX;
    if (nums[left] >= target) {

        return 1;
    }
    if (sum >= target) {
        res = 2;
    }
    while (right < nums.size()) {

        if (left >= right) {
            return res;
        }
        if (sum >= target) {

            sum -= nums[left];
            left++;
        } else {

            right++;
            if (right < nums.size()) {
                sum += nums[right];
            }
        }
        if (sum >= target) {

            res = min(res, right - left + 1);
        }
    }
    return res == INT_MAX ? 0 : res;
}
```

## 3. 无重复字符的最长子串

> 给定一个字符串 `s` ，请你找出其中不含有重复字符的 **最长 子串** 的长度。

```c++
int lengthOfLongestSubstring(string s) {

    if (s.size() == 0) {

        return 0;
    }

    unordered_map<char, int> mp;
    mp[s[0]] = 1;
    int i = 0, j = 1, res = 1;
    while (j < s.size()) {

        if (mp[s[j]] == 0) {
            mp[s[j]] = 1;
            res = max(res, j - i + 1);
            j++;
        } else {
            while (mp[s[j]] != 0) {
                mp[s[i]] = 0;
                i++;
            }
        }
    }
    return res;
}
```

## 561. 数组拆分 I

> 给定长度为 `2n` 的整数数组 `nums` ，你的任务是将这些数分成 `n` 对, 例如 `(a1, b1), (a2, b2), ..., (an, bn)` ，使得从 `1` 到 `n` 的 `min(ai, bi)` 总和最大。
>
> 返回该 **最大总和** 。

```c++
int arrayPairSum(vector<int>& nums) {
    sort(nums.begin(), nums.end());
    int sum = 0;
    for (int i = 0; i < nums.size(); i += 2) {
        sum += nums[i];
    }
    return sum;
}
```

## 455. 分发饼干

> 假设你是一位很棒的家长，想要给你的孩子们一些小饼干。但是，每个孩子最多只能给一块饼干。
>
> 对每个孩子 `i`，都有一个胃口值 `g[i]`，这是能让孩子们满足胃口的饼干的最小尺寸；并且每块饼干 `j`，都有一个尺寸 `s[j]` 。如果 `s[j] >= g[i]`，我们可以将这个饼干 `j` 分配给孩子 `i` ，这个孩子会得到满足。你的目标是满足尽可能多的孩子，并输出这个最大数值。

```c++
int findContentChildren(vector<int>& g, vector<int>& s) {
    sort(g.begin(), g.end());
    sort(s.begin(), s.end());
    int i = 0, j = 0, res = 0;
    while (i < g.size() && j < s.size()) {
        if (s[j] >= g[i]) {
            res++;
            i++;
        }
        j++;
    }
    return res;
}
```

## 860. 柠檬水找零

> 在柠檬水摊上，每一杯柠檬水的售价为 `5` 美元。顾客排队购买你的产品，（按账单 `bills` 支付的顺序）一次购买一杯。
>
> 每位顾客只买一杯柠檬水，然后向你付 `5` 美元、`10` 美元或 `20` 美元。你必须给每个顾客正确找零，也就是说净交易是每位顾客向你支付 `5` 美元。
>
> 注意，一开始你手头没有任何零钱。
>
> 给你一个整数数组 `bills` ，其中 `bills[i]` 是第 `i` 位顾客付的账。如果你能给每位顾客正确找零，返回 `true` ，否则返回 `false` 。

```c++
bool lemonadeChange(vector<int>& bills) {

    int five = 0, ten = 0, i = 0;
    while (i < bills.size()) {
        if (bills[i] == 5) {
            five++;
        } else if (bills[i] == 10) {
            if (five == 0) {

                return false;
            }
            five--;
            ten++;
        } else {
            if (ten > 0 && five > 0) {
                five--;
                ten--;
            } else if (five >= 3) {
                five -= 3;
            } else {
                return false;
            }
        }
        i++;
    }
    return true;
}
```

