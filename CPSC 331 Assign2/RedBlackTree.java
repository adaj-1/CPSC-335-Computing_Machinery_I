/*
 * CPSC 331: Assignment 2 Question 4
 * ca.ucalgry.cpsc331.RedBlackTree
 * 
 * Author: Jada Li
 * UCID: 30016807
 */

package ca.ucalgary.cpsc331;

/*
 * Description: Node class to build Red Black Tree
 */
class Node
{
	int key;							
	int colour; 						// 0 for red, 1 for black

	Node parent;
	Node leftChild;
	Node rightChild;	
}

/*
 * Description: Red Black Tree implementation
 * Citation: Introduction To Algorithms 3rd Ed.
 */
public class RedBlackTree implements Dictionary{
	
	static final int RED = 0;						// indicated red node
	static final int BLACK = 1;						// indicates black node

	private Node tRoot;								// root node
	private Node tNil;								// tnil node
	private String redBlackTree = "";				// to hold redBlackTree format string
	private int toStringCount = 0;					// to indicate whether toString has been run before
	
	/*
	 * Description: Red Black Tree Constructor. Initialized to empty tree.
	 */
	RedBlackTree()
	{
		tNil = new Node();					// creating new leaf/tNil node
		tNil.colour = BLACK;				// filling with tNil properties
		tNil.leftChild = null;				// setting to null
		tNil.rightChild = null;				// setting to null
		tRoot = tNil;						// initialize empty tree
	}
	
	/*
	 * Description: Iterative Tree Search algorithm find value within RBT
	 * 
	 * @param	value	is searched for among the RBT keys
	 * 
	 * @returns	x		the node which the value belongs to
	 */
	private Node iterativeTreeSearch(int value)
	{
		Node x = tRoot;							// start  search at root
		
		while (x != tNil && value != x.key)		// while value is not tNIL or the root node
		{
			if (value < x.key)
			{
				x = x.leftChild;				// check left sub trees
			}
			else
			{
				x = x.rightChild;				// check right sub trees
			}
		}
		return x;
	}

	/*
	 * Description: find the minimum  key in the RBT
	 * 
	 * @param	min		given node to find the minimum element in subtree
	 * 
	 * @return	min		nod that holds the minimum element
	 */
	private Node treeMinimum(Node min)
	{
		while (min.leftChild != tNil)		// RBT property guarantees finding tree minimum through leftchild
		{
			min = min.leftChild;
		}
		
		return min;
	}
		
	/*
	 * Description: checks if RBT is empty
	 * 
	 * @returns		NullPointerException	if RBT is empty
	 * 				false 					if RBT is not empty
	 */
	@Override
	public boolean empty() 
	{
		if(tRoot == tNil)
		{
			throw new NullPointerException("Red-Black Tree is empty.\n");		// throws empty exception
		}
		return false;
	}

	/*
	 * Description: restores Red-Black properties after rbInsert
	 * 
	 * @param	insertedNode 	to determine where to begin restoring RB properties
	 */
	private void rbInsertFixUp(Node insertedNode)
	{
		Node tmpNode;															
		
		/* while loop maintained if 
		 * a) insertedNode is red
		 * b) if insertedNode.parent is the root, then insertedNode.parent is black
		 * c) property 2 or property 4 is violated
		 */
		while (insertedNode.parent.colour == RED)		
		{		
			if (insertedNode.parent == insertedNode.parent.parent.leftChild)		// fixing right subtree
			{
				tmpNode = insertedNode.parent.parent.rightChild;
				
				if (tmpNode.colour == RED)
				{
					/* CASE 1: insertedNode's right uncle tmpNode is RED */
					insertedNode.parent.colour = BLACK;
					tmpNode.colour = BLACK;
					insertedNode.parent.parent.colour = RED;
					insertedNode = insertedNode.parent.parent;
				}
				else if (insertedNode == insertedNode.parent.rightChild)
				{
					/* CASE 2:insertedNode's right uncle tmpNode is BLACK and insertedNode is a right child */
					insertedNode = insertedNode.parent;
					leftRotate(insertedNode);
				}
				else
				{
					/* CASE 3: insertedNode's right uncle tmpNode is BLACK and insertedNode is a left child*/
					insertedNode.parent.colour = BLACK;
					insertedNode.parent.parent.colour = RED;
					rightRotate(insertedNode.parent.parent);
				}
			}
			else																	// fixing left subtree
			{
				tmpNode = insertedNode.parent.parent.leftChild;
				
				if (tmpNode.colour == RED)
				{
					/* CASE 1: insertedNode's left uncle tmpNode is RED */
					insertedNode.parent.colour = BLACK;			
					tmpNode.colour = BLACK;
					insertedNode.parent.parent.colour = RED;
					insertedNode = insertedNode.parent.parent;
				}
				else if (insertedNode == insertedNode.parent.leftChild)
				{
					/* CASE 2:insertedNode's left uncle tmpNode is BLACK and insertedNode is a right child */
					insertedNode = insertedNode.parent;
					rightRotate(insertedNode);
				} 
				else
				{
					/* CASE 3: insertedNode's left uncle tmpNode is BLACK and insertedNode is a left child*/
					insertedNode.parent.colour = BLACK;
					insertedNode.parent.parent.colour = RED;
					leftRotate(insertedNode.parent.parent);
				}
			}
		}	
		tRoot.colour = BLACK;							
	}

	/*
	 * Description: to insert a new value into the RBT
	 * 
	 * @param	key		value to be inserted
	 */
	@Override
	public void insert(int key) 
	{
		Node insertedNode = new Node();			// initialize new node
		insertedNode.key = key;
		insertedNode.colour = RED;
		insertedNode.parent = tNil;	
		insertedNode.leftChild = tNil;
		insertedNode.rightChild = tNil;
	
		Node tmpNode = tNil;					
		Node rootNode = tRoot;					
		
		while (rootNode != tNil)
		{
			tmpNode = rootNode;
			 
			if (insertedNode.key < rootNode.key)		// determining placement of insertedNode based on key value
			{
				rootNode = rootNode.leftChild;
			}
			else
			{
				rootNode = rootNode.rightChild;
			}
		}
		
		insertedNode.parent = tmpNode;					// setting tmpNode as insertedNode's parent
		
		if (tmpNode == tNil)							// if it is tNil, the insertedNode must be the tRoot
		{
			tRoot = insertedNode;
		}
		else if (insertedNode.key < tmpNode.key)		// determining if insertedNode is left or right child
		{
			tmpNode.leftChild = insertedNode;
		}
		else
		{
			tmpNode.rightChild = insertedNode;
		}
		
		rbInsertFixUp(insertedNode);					// maintain property of red-black tree
	}

	/*
	 * Description: pivots left around link
	 * 
	 * @param	rotate		the node that pivots
	 */
	private void leftRotate(Node rotate)
	{
		Node holdRotate = rotate.rightChild;			// set holdRotate
		rotate.rightChild = holdRotate.leftChild;		// turn holdRotate's left subtree into rotate's right subtree
		
		if (holdRotate.leftChild != tNil)
		{
			holdRotate.leftChild.parent = rotate;
		}
		
		holdRotate.parent = rotate.parent;				// links rotate's parents to holdRotate's
		
		if (rotate.parent == tNil)						
		{
			this.tRoot = holdRotate;
		}
		else if (rotate == rotate.parent.leftChild)
		{
			rotate.parent.leftChild = holdRotate;
		}
		else
		{
			rotate.parent.rightChild = holdRotate;
		}
		
		holdRotate.leftChild = rotate;					// put rotate on holdRotate's left
		rotate.parent = holdRotate;
	}
	
	/*
	 * Description: pivots right around link
	 * 
	 * @param	rotate		the node that pivots
	 */
	private void rightRotate(Node rotate)
	{
		Node holdRotate = rotate.leftChild;				// set holdRotate
		rotate.leftChild = holdRotate.rightChild;		// turn holdRotate's right subtree into rotate's left subtree
		
		if (holdRotate.rightChild != tNil)
		{
			holdRotate.rightChild.parent = rotate;
		}
		
		holdRotate.parent = rotate.parent;				// links rotate's parents to holdRotate's
		
		if (rotate.parent == tNil)
		{
			this.tRoot = holdRotate;
		}
		else if (rotate == rotate.parent.rightChild)
		{
			rotate.parent.rightChild = holdRotate;
		}
		else
		{
			rotate.parent.leftChild = holdRotate;
		}
		
		holdRotate.rightChild = rotate;					// put rotate on holdRotate's right
		rotate.parent = holdRotate;
	}

	/*
	 * Description: to move subtrees around within the RBT
	 * 
	 * @param	deleted		the subtree rooted at this node
	 * 			replace		the subtree that was deleted
	 */
	private void rbTransplant(Node deleted, Node replace)
	{
		if (deleted.parent == tNil)							// handle if deleted subtree is root of  RBT
		{
			tRoot = replace;
		}
		else if (deleted == deleted.parent.leftChild)		// if deleted is a left child, update parent
		{
			deleted.parent.leftChild = replace;
		}
		else
		{
			deleted.parent.rightChild = replace;			// if deleted is a right child, update parent
		}
		
		replace.parent = deleted.parent;					// take parent of deleted and assign to replacement
	}
	
	/*
	 * Description: restores RBT properties after deletion
	 * 
	 * @param	fix		where RBT properties must be restored at
	 */
	private void rbDeleteFixUp(Node fix)
	{
		Node tmpNode;
		
		while (fix != tRoot &&  fix.colour == BLACK)
		{
			if (fix == fix.parent.leftChild)
			{
				/* maintains right subtree */
				tmpNode = fix.parent.rightChild;
				
				if (tmpNode.colour == RED)
				{
					/* CASE 1: fix's sibling tmpNode is red */
					tmpNode.colour = BLACK;
					fix.parent.colour = RED;
					leftRotate(fix.parent);
					tmpNode = fix.parent.rightChild;
				}
				
				if (tmpNode.leftChild.colour == BLACK && tmpNode.rightChild.colour == BLACK)
				{
					/* CASE 2: fix's sibling tmpNode is BLACK and both of tmpNode's children are BLACK */
					tmpNode.colour = RED;
					fix = fix.parent;
				}
				else if (tmpNode.rightChild.colour == BLACK)
				{
					/* CASE 3: fix's sibling tmpNode is BLACK, tmpNode's left child is RED, and tmpNode's right child is BLACK */
					tmpNode.leftChild.colour = BLACK;
					tmpNode.colour = RED;
					rightRotate(tmpNode);
					tmpNode = fix.parent.rightChild;
				}
				
				/* CASE 4: fix's sibling tmpNode is BLACK, and tmpNode's right child is RED */
				tmpNode.colour = fix.parent.colour;
				fix.parent.colour = BLACK;
				tmpNode.rightChild.colour = BLACK;
				leftRotate (fix.parent);
				fix = tRoot;
			}
			else
			{	/* maintains left subtree */
				tmpNode = fix.parent.leftChild; 
				
				if (tmpNode.colour == RED)
				{
					/* CASE 1: fix's sibling tmpNode is red */
					tmpNode.colour = BLACK;
					fix.parent.colour = RED;
					rightRotate(fix.parent);
					tmpNode = fix.parent.leftChild;
				}
				
				if (tmpNode.rightChild.colour == BLACK && tmpNode.leftChild.colour == BLACK)
				{
					/* CASE 2: fix's sibling tmpNode is BLACK and both of tmpNode's children are BLACK */
					tmpNode.colour = RED;
					fix = fix.parent;
				}
				else if (tmpNode.leftChild.colour == BLACK)
				{
					/* CASE 3: fix's sibling tmpNode is BLACK, tmpNode's left child is RED, and tmpNode's right child is BLACK */
					tmpNode.rightChild.colour = BLACK;
					tmpNode.colour = RED;
					leftRotate(tmpNode);
					tmpNode = fix.parent.leftChild;
				}
				
				/* CASE 4: fix's sibling tmpNode is BLACK, and tmpNode's right child is RED */
				tmpNode.colour = fix.parent.colour;
				fix.parent.colour = BLACK;
				tmpNode.leftChild.colour = BLACK;
				rightRotate (fix.parent);
				fix = tRoot;
			}
		}
		
		fix.colour = BLACK;
	}
	
	/*
	 * Description: deleting node from RBT
	 * 
	 * @param	key		the value of the node to be removed from the tree
	 */
	@Override
	public void delete(int key) 
	{
		Node deleteNode = iterativeTreeSearch(key);					// find node of key to be deleted
		
		Node holdNode = deleteNode;									// to hold deletedNode data
		Node fillNode;												// node to fill deleted space
		
		int originalColour = holdNode.colour;
		
		if (deleteNode.leftChild == tNil)
		{
			fillNode =deleteNode.rightChild;
			rbTransplant(deleteNode, deleteNode.rightChild);		// transplants right child to deleted node position
		}
		else if (deleteNode.rightChild == tNil)
		{
			fillNode = deleteNode.leftChild;
			rbTransplant(deleteNode, deleteNode.leftChild);			// transplants left child to deleted node position
		}
		else
		{
			holdNode = treeMinimum(deleteNode.rightChild);			// fills holdNode with the minimum key from deletedNode's right subtree
			originalColour = holdNode.colour;
			fillNode = holdNode.rightChild;
			
			if (holdNode.parent == deleteNode)
			{
				fillNode.parent = holdNode;
			}
			else
			{
				rbTransplant(holdNode,holdNode.rightChild);			// if holdNode.parent is not deleteNode, transplant holdNode to be the right child
				holdNode.rightChild = deleteNode.rightChild;
				holdNode.rightChild.parent = holdNode;
			}
			
			rbTransplant(deleteNode, holdNode);						// transplant deleteNode with holdNode
			holdNode.leftChild = deleteNode.leftChild;				
			holdNode.leftChild.parent = holdNode;
			holdNode.colour = deleteNode.colour;					// maintaining deleteNode colour		
		}
		
		if (originalColour == BLACK)
		{
			rbDeleteFixUp(fillNode);								// restore RBT properties
		}
	}

	/*
	 * Description: determines if key is a member of RBT
	 * 
	 * @param	key		value of node to search for in RBT
	 * 
	 * @return	true	if it exits in RBT	
	 */
	@Override
	public boolean member(int key) 
	{
		if (iterativeTreeSearch(key) != tNil)			// if key is in the RBT and not tNil
		{
			return true;
		}
		return false;
	}
	
	/*
	 * Description: prints and creates pre-order tree walk string of the RBT
	 * 
	 * @param	startingNode		node to start at
	 * 
	 * @return addressColourKey		string that has the address, colour, and key of the node
	 */
	private String preOrderTreeWalk(Node startingNode)
	{
		String addressColourKey = "";				// initializing string
		
			if (startingNode != tNil)				// does not include external nodes
			{	
				String colour;
				if (startingNode.colour == 0)		// converting colour for nodes to string
				{
					colour = "red";
				}
				else
				{
					colour = "black";
				}
				
				addressColourKey ="*"+findAddress(startingNode)+":"+ colour +":" + startingNode.key + "\n";		// concatenation of address, colour, and key
				
				redBlackTree += addressColourKey;					// concatenation for toString method
				
				preOrderTreeWalk(startingNode.leftChild);			// recursion until finished all left children
				preOrderTreeWalk(startingNode.rightChild);			// recursion until finished all right children
			}
		
			
		return addressColourKey;
	}
	
	/*
	 * Description: finds address of node
	 * 
	 * @param	node			the node to find the address of
	 * 
	 * @return	finalAddress	the address of the node
	 */
	private String findAddress(Node node)
	{
		String address = "";									// starting at root
		
		Node tmp = node;
		
		while (tmp != tRoot)
		{
			if (tmp == tmp.parent.rightChild)					// check if node is right child of root
			{
				address = address.concat("R");					// node is a right child
			}
			else
			{
				address = address.concat("L");					// node is a left child
			}
			tmp = tmp.parent;									// loop until tmp.parent is tRoot or tNil
		}
		
		/* CITATION: https://devqa.io/reverse-string-java/ */
		String finalAddress = "";
		
		for (char c : address.toCharArray())					// reversing string for final address
		{
			finalAddress = c + finalAddress;
		}
				
		return finalAddress;
	}
	
	/*
	 * Description: displays	RBT address:colour:key
	 * 
	 * @return	redBlackTree	string of all the nodes in the tree
	 */
	@Override
	public String toString()			
	{	
		if(toStringCount != 0)			
		{
			redBlackTree = "";			// clear string if toString has been called previously
		}
		
		if(empty())						// returns empty string if tree is empty
		{
			return redBlackTree;
		}
		
		preOrderTreeWalk(tRoot);		// build string in pre-order tree walk
		
		toStringCount++;				// indicate that toString has been called
		return redBlackTree;	
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}
