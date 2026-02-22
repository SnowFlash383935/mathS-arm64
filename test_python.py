import fast_arm
import sys

text = "Python-to-ASM is magic!"
result = fast_arm.reverse(text)
print(f"Original: {text}")
print(f"Reversed: {result}")

if result == text[::-1]:
    print("SUCCESS!")
else:
    print("FAIL!")
    sys.exit(1)
  
