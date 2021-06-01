package ca.ucalgary.cpsc331;

public class testRedBlackTree {

	public static void main(String[] args)
	{
		System.out.printf("starting my test\n");
		RedBlackTree rbTree = new RedBlackTree();
		
		rbTree.insert(55);
		rbTree.insert(40);
		rbTree.insert(65);
		rbTree.insert(60);
		rbTree.insert(75);
		rbTree.insert(57);
		
		
		
		System.out.printf("toString()\n");
		rbTree.toString();

		rbTree.delete(40);
		System.out.printf("after delete\n");
		rbTree.toString();

	}	
}
